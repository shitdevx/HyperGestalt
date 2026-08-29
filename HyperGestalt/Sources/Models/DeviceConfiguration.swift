import Foundation
import UIKit

class DeviceConfigurationManager {
    static let shared = DeviceConfigurationManager()
    
    private let fileManager = FileManager.default
    private var currentConfiguration: DeviceConfiguration?
    
    func loadConfiguration() -> DeviceConfiguration? {
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let configURL = documentsURL.appendingPathComponent("current_config.plist")
            
            if fileManager.fileExists(atPath: configURL.path) {
                do {
                    let data = try Data(contentsOf: configURL)
                    return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? DeviceConfiguration
                } catch {
                    print("[ERROR] Failed to load configuration: \(error)")
                }
            }
        }
        
        return createDefaultConfiguration()
    }
    
    func saveConfiguration(_ config: DeviceConfiguration) throws {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let configURL = documentsURL.appendingPathComponent("current_config.plist")
        
        let data = try PropertyListSerialization.data(fromPropertyList: config, format: .xml, options: 0)
        try data.write(to: configURL)
        
        currentConfiguration = config
    }
    
    func createDefaultConfiguration() -> DeviceConfiguration {
        return DeviceConfiguration(
            deviceModel: "",
            soC: .a7,
            hardwareCapabilities: HardwareCapabilities(),
            featureFlags: [:],
            systemCapabilities: [:],
            customProperties: [:],
            timestamp: Date()
        )
    }
}

struct DeviceConfiguration: Codable {
    let deviceModel: String
    let soC: SoCType
    let hardwareCapabilities: HardwareCapabilities
    let featureFlags: [String: Any]
    let systemCapabilities: [String: Any]
    let customProperties: [String: Any]
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case deviceModel, soC, hardwareCapabilities, featureFlags, systemCapabilities, customProperties, timestamp
    }
}