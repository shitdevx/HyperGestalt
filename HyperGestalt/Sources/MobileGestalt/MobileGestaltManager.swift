import Foundation
import UIKit
import Alamofire
import RxSwift

class MobileGestaltManager {
    static let shared = MobileGestaltManager()
    
    private let plistManager = PlistManager.shared
    private var deviceDatabase = DeviceDatabase.shared
    private var privilegeEscalation = PrivilegeEscalationManager.shared
    
    // MARK: - Core Operations
    func applyDeviceModel(_ modelIdentifier: String) async throws -> [String: Any] {
        let device = deviceDatabase.getDevice(modelIdentifier)
        guard let device else {
            throw HyperGestaltError.deviceNotSupported("Device model not found")
        }
        
        let configuration = deviceDatabase.createConfiguration(from: device)
        
        try await privilegeEscalation.applyConfiguration(configuration)
        
        return try persistDeviceConfiguration(modelIdentifier, configuration)
    }
    
    func getGestaltProperties() -> [String: Any] {
        return plistManager.readPlist(path: "/var/mobile/Library/Preferences/MobileGestalt.plist")
    }
    
    func updateCapability(_ key: String, value: Any) async throws {
        let config = privilegeEscalation.getKernelReadWrite()
        guard let config else {
            throw HyperGestaltError.noPrivilegeEscalation
        }
        
        try await config.updateCapability(key, value: value)
    }
    
    // MARK: - Persistence
    private func persistDeviceConfiguration(_ modelIdentifier: String, _ configuration: DeviceConfiguration) -> [String: Any] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let configURL = documentsURL.appendingPathComponent("\(modelIdentifier)_config.plist")
        
        var plistData: [String: Any] = [:]
        
        if let soCString = configuration.soC.rawValue {
            plistData["SoC"] = soCString
        }
        
        plistData["DeviceModel"] = modelIdentifier
        plistData["HardwareCapabilities"] = configuration.hardwareCapabilities
        plistData["FeatureFlags"] = configuration.featureFlags
        plistData["SystemCapabilities"] = configuration.systemCapabilities
        plistData["Timestamp"] = configuration.timestamp
        
        plistManager.writePlist(plistData, path: configURL.path)
        
        return plistData
    }
}

extension DeviceDatabase {
    func createConfiguration(from device: DeviceModel) -> DeviceConfiguration {
        let hardwareCapabilities = device.specifications.toHardwareCapabilities()
        
        var featureFlags: [String: Any] = [:]
        var systemCapabilities: [String: Any] = [:]
        
        for feature in device.capabilities.features {
            featureFlags[feature.key] = feature.value
        }
        
        return DeviceConfiguration(
            deviceModel: device.modelIdentifier,
            soC: device.specifications.soc,
            hardwareCapabilities: hardwareCapabilities,
            featureFlags: featureFlags,
            systemCapabilities: systemCapabilities,
            customProperties: [:],
            timestamp: Date()
        )
    }
}

extension DeviceSpecifications {
    func toHardwareCapabilities() -> HardwareCapabilities {
        let neuralEngine = NeuralEngineSpec(
            coreCount: 16,
            architecture: "A17",
            performanceCores: 8,
            efficiencyCores: 4
        )
        
        let gpu = GPUSpec(
            coreCount: 1024,
            architecture: "M4",
            computeUnits: 384,
            vramb: 128
        )
        
        let cpu = CPUSpec(
            performanceCores: 8,
            efficiencyCores: 4,
            maxBoostFrequency: 3.5,
            architecture: "Oak"
        )
        
        let memory = MemorySpec(
            ramGB: ramGB,
            storageTypes: [.nvme],
            lpddr: LPDDRSpec(version: "LPDDR5X", speedGbps: 8.5)
        )
        
        return HardwareCapabilities(
            neuralEngine: neuralEngine,
            gpu: gpu,
            cpu: cpu,
            memory: memory
        )
    }
}
