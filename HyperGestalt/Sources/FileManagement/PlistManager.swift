import Foundation
class PlistManager {
    static let shared = PlistManager()
    func readPlist(path: String) -> [String: Any] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else { return [:] }
        return plist
    }
    func writePlist(_ dict: [String: Any], path: String) {
        if let data = try? PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0) {
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }
}
