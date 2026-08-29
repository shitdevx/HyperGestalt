import Foundation
import UIKit

// MARK: - Error Types
enum HyperGestaltError: Error, LocalizedError {
    case noPrivilegeEscalation
    case fileOperationFailed(String)
    case invalidPlistData
    case configurationInvalid(String)
    case exploitFailed(String)
    case deviceNotSupported(String)
    
    var errorDescription: String? {
        switch self {
        case .noPrivilegeEscalation:
            return "Privilege escalation failed. Make sure your device is jailbroken."
        case .fileOperationFailed(let path):
            return "Failed to access file at \(path)."
        case .invalidPlistData:
            return "Invalid plist data format."
        case .configurationInvalid(let reason):
            return "Invalid configuration: \(reason)"
        case .exploitFailed(let reason):
            return "Exploit failed: \(reason)"
        case .deviceNotSupported(let reason):
            return "Device not supported: \(reason)"
        }
    }
}

// MARK: - Device Information
struct DeviceInfo: Codable {
    let model: String
    let soC: SoCType
    let ram: Int
    let isArm64E: Bool
    let firmwareVersion: String
    let hardwareVersion: String
}

enum SoCType: String, CaseIterable, Codable {
    case a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, m1, m2, m3, m4
    
    var name: String {
        switch self {
        case .a7: return "Apple A7"
        case .a8: return "Apple A8"
        case .a9: return "Apple A9"
        case .a10: return "Apple A10"
        case .a11: return "Apple A11"
        case .a12: return "Apple A12"
        case .a13: return "Apple A13"
        case .a14: return "Apple A14"
        case .a15: return "Apple A15"
        case .a16: return "Apple A16"
        case .a17: return "Apple A17 Pro"
        case .a18: return "Apple A18"
        case .m1: return "Apple M1"
        case .m2: return "Apple M2"
        case .m3: return "Apple M3"
        case .m4: return "Apple M4"
        }
    }
}

// MARK: - Jailbreak Detection
struct JailbreakInfo {
    let hasJailbreak: Bool
    let type: JailbreakType
    let version: String?
}

enum JailbreakType {
    case cydia, sileo, zap, other, unknown
}
