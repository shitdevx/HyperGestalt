import Foundation
import UIKit
import Alamofire
import RxSwift
import Swinject

// MARK: - Notification Names
extension Notification {
    static let appWillResignActive = Notification.Name("appWillResignActive")
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
    static let deviceConfigurationChanged = Notification.Name("deviceConfigurationChanged")
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var isInitialized: Bool = false
    @Published var isJailbroken: Bool = false
    @Published var privilegeEscalated: Bool = false
    @Published var currentDeviceState: DeviceState?
    @Published var isReadOnlyMode: Bool = false
    @Published var error: Error?
    
    func initialize() async {
        // Initialize app state
        isInitialized = true
    }
}

class DeviceState {
    let model: String
    let soC: SoCType
    let ramGB: Int
    let capabilities: [FeatureFlag]
    let systemVersion: String
    
    init(model: String = "", soC: SoCType = .a7, ramGB: Int = 0, capabilities: [FeatureFlag] = [], systemVersion: String = "") {
        self.model = model
        self.soC = soC
        self.ramGB = ramGB
        self.capabilities = capabilities
        self.systemVersion = systemVersion
    }
}
