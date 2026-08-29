import Foundation
import UIKit

extension Notification {
    static let deviceConfigurationChanged = Notification.Name("deviceConfigurationChanged")
}
class AppState: ObservableObject {
    @Published var isInitialized: Bool = false
    @Published var isJailbroken: Bool = false
    @Published var privilegeEscalated: Bool = false
    @Published var currentDeviceState: DeviceState?
    @Published var isReadOnlyMode: Bool = false
    @Published var error: Error?
    func initialize() async { isInitialized = true }
}
class DeviceState {
    let model: String
    let soC: SoCType
    let ramGB: Int
    let capabilities: [FeatureFlag]
    let systemVersion: String
    init(model: String = "", soC: SoCType = .a14, ramGB: Int = 0, capabilities: [FeatureFlag] = [], systemVersion: String = "") {
        self.model = model; self.soC = soC; self.ramGB = ramGB; self.capabilities = capabilities; self.systemVersion = systemVersion
    }
}
struct FeatureFlag: Codable { let key: String; let value: Bool }
