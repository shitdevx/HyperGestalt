import Foundation

class DeviceConfigurationManager {
    static let shared = DeviceConfigurationManager()
    private let fileManager = FileManager.default
    private var currentConfiguration: DeviceConfiguration?
    func loadConfiguration() -> DeviceConfiguration? { createDefaultConfiguration() }
    func saveConfiguration(_ config: DeviceConfiguration) throws {
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("current_config.plist")
        let data = try PropertyListSerialization.data(fromPropertyList: ["deviceModel": config.deviceModel], format: .xml, options: 0)
        try data.write(to: url)
        currentConfiguration = config
    }
    func createDefaultConfiguration() -> DeviceConfiguration {
        return DeviceConfiguration(deviceModel: "", soC: .a14, hardwareCapabilities: HardwareCapabilities(), featureFlags: [:], systemCapabilities: [:], customProperties: [:], timestamp: Date())
    }
}

struct DeviceConfiguration: Codable {
    let deviceModel: String
    let soC: SoCType
    let hardwareCapabilities: HardwareCapabilities
    let featureFlags: [String: String]
    let systemCapabilities: [String: String]
    let customProperties: [String: String]
    let timestamp: Date
}

struct HardwareCapabilities: Codable { init() {} }
