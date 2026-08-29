import Foundation
import UIKit

class JailbreakDetector {
    static func detect() async -> JailbreakInfo {
        let fileManager = FileManager.default
        
        let jailbreakPaths = [
            "/private/var/lib/apt",
            "/var/lib/apt",
            "/usr/bin/cydia",
            "/Applications/Cydia.app",
            "/var/lib/jb",
            "/var/jb",
            "/Library/Preferences/com.saurik.Cydia",
            "/Library/Preferences/com.filza.launcher",
            "/Library/Preferences/com.saurik.Cydia.plist"
        ]
        
        var detectedType: JailbreakType = .unknown
        var version: String? = nil
        
        for path in jailbreakPaths {
            if fileManager.fileExists(atPath: path) {
                detectedType = detectSpecificJailbreak(path: path)
                version = getJailbreakVersion(type: detectedType)
                break
            }
        }
        
        let hasJailbreak = detectedType != .unknown
        return JailbreakInfo(hasJailbreak: hasJailbreak, type: detectedType, version: version)
    }
    
    private static func detectSpecificJailbreak(path: String) -> JailbreakType {
        if path.contains("cydia") {
            return .cydia
        } else if path.contains("sileo") {
            return .sileo
        } else if path.contains("filza") || path.contains("zap") {
            return .zap
        } else {
            return .other
        }
    }
    
    private static func getJailbreakVersion(type: JailbreakType) -> String? {
        switch type {
        case .cydia:
            return "Cydia"
        case .sileo:
            return "Sileo"
        case .zap:
            return "Zap"
        case .other:
            return "Unknown"
        case .unknown:
            return nil
        }
    }
}