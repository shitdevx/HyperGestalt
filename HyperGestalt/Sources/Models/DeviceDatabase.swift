import Foundation
import UIKit
import Alamofire
import RxSwift

class DeviceDatabase: ObservableObject {
    @Published var devices: [DeviceModel] = []
    @Published var isLoading: Bool = false
    
    private let jsonDecoder = JSONDecoder()
    private let fileManager = FileManager.default
    
    // MARK: - Initialization
    static let shared = DeviceDatabase()
    
    private init() {
        loadDeviceDatabase()
    }
    
    // MARK: - Public API
    func getDevice(_ modelIdentifier: String) -> DeviceModel? {
        return devices.first { $0.modelIdentifier == modelIdentifier }
    }
    
    func getDevices(for category: DeviceCategory? = nil, soC: SoCType? = nil) -> [DeviceModel] {
        var filtered = devices
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let soC = soC {
            filtered = filtered.filter { $0.soC == soC }
        }
        
        return filtered
    }
    
    func searchDevices(query: String) -> [DeviceModel] {
        guard !query.isEmpty else { return devices }
        
        let lowercasedQuery = query.lowercased()
        return devices.filter { device in
            device.marketingName.lowercased().contains(lowercasedQuery) ||
            device.modelIdentifier.lowercased().contains(lowercasedQuery) ||
            device.soC.rawValue.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - File Operations
    private func loadDeviceDatabase() {
        isLoading = true
        
        guard let bundlePath = Bundle.main.path(forResource: "devices", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)) else {
            print("[ERROR] Could not load device database")
            isLoading = false
            return
        }
        
        do {
            devices = try jsonDecoder.decode([DeviceModel].self, from: data)
            isLoading = false
        } catch {
            print("[ERROR] Failed to decode device database: \(error)")
            isLoading = false
        }
    }
}

struct DeviceModel: Codable, Identifiable {
    let id = UUID()
    let modelIdentifier: String
    let marketingName: String
    let category: DeviceCategory
    let releaseYear: Int
    let specifications: DeviceSpecifications
    let capabilities: DeviceCapabilities
    let gestaltProperties: [String: Any]
    
    enum DeviceCategory: String, CaseIterable, Codable {
        case iphone, ipad, ipod, appleTv, homepod
    }
    
    var displayName: String {
        return "\(marketingName) (\(modelIdentifier))"
    }
}

struct DeviceSpecifications: Codable {
    let soc: SoCType
    let ramGB: Int
    let storageOptions: [Int]
    let display: DisplaySpec
    let camera: CameraSpec
    let dimensions: Dimensions
    let battery: BatterySpec
    let releaseDate: Date
}

struct DisplaySpec: Codable {
    let size: String
    let resolution: String
    let refreshRate: Int
    let technology: DisplayTechnology
    let hdrSupport: Bool
}

enum DisplayTechnology: String, CaseIterable, Codable {
    case lcd, oled, miniRetina, retinaXdr, oledXdr
}

struct CameraSpec: Codable {
    let wide: CameraModule
    let ultraWide: CameraModule
    let telephoto: CameraModule
    let depth: DepthSensorSpec
    let front: CameraModule
}

struct CameraModule: Codable {
    let aperture: String
    let sensorSize: String
    let opticalZoom: Double
    let digitalZoom: Double
    let videoCapabilities: [VideoCapability]
}

struct DepthSensorSpec: Codable {
    let hasLiDAR: Bool
    let hasTimeOfFlight: Bool
    let accuracy: Double
}

struct Dimensions: Codable {
    let height: Double
    let width: Double
    let thickness: Double
    let weight: Double
}

struct BatterySpec: Codable {
    let capacity: Int
    let fastCharging: Bool
    let wirelessCharging: Bool
    let maxChargeRate: Double
}

enum VideoCapability: String, CaseIterable, Codable {
    case cinematic4k60fps, proRes422, proRaw, hdr10, dolbyVision, hevc, avc
}

struct DeviceCapabilities: Codable {
    let features: [FeatureFlag]
    let entitlements: [String: Any]
    let hardwareCapabilities: HardwareCapabilities
}

struct FeatureFlag: Codable {
    let key: String
    let value: Bool
    let description: String
    let requiresHardware: Bool
    let versionIntroduced: String
}

struct HardwareCapabilities: Codable {
    let neuralEngine: NeuralEngineSpec
    let gpu: GPUSpec
    let cpu: CPUSpec
    let memory: MemorySpec
}

struct NeuralEngineSpec: Codable {
    let coreCount: Int
    let architecture: String
    let performanceCores: Int
    let efficiencyCores: Int
}

struct GPUSpec: Codable {
    let coreCount: Int
    let architecture: String
    let computeUnits: Int
    let vramb: Int
}

struct CPUSpec: Codable {
    let performanceCores: Int
    let efficiencyCores: Int
    let maxBoostFrequency: Double
    let architecture: String
}

struct MemorySpec: Codable {
    let ramGB: Int
    let storageTypes: [StorageType]
    let lpddr: LPDDRSpec
}

enum StorageType: String, CaseIterable, Codable {
    case nvme, sdcard, eMMC
}

struct LPDDRSpec: Codable {
    let version: String
    let speedGbps: Double
}