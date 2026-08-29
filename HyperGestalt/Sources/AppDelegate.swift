import Foundation
import UIKit
import Alamofire
import RxSwift
import Swinject
import PrivilegeEscalation
import MobileGestalt
import Capabilities
import FileManagement
import UI

@MainActor
class HyperGestaltAppDelegate: NSObject, UIApplicationDelegate {
    static let shared = HyperGestaltAppDelegate()
    
    var window: UIWindow?
    var container: Swinject.Container!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        setupDependencyInjection()
        setupPrivilegeEscalation()
        
        let splashScreen = SplashScreenViewController()
        splashScreen.onSplashComplete = { [weak self] in
            self?.navigateToMainInterface()
        }
        
        window?.rootViewController = splashScreen
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setupDependencyInjection() {
        container = Swinject.Container()
        
        container.register(AppState.self) { _ in AppState() }
        container.register(DeviceDatabase.self) { r in DeviceDatabase() }
        container.register(DeviceConfigurationManager.self) { r in DeviceConfigurationManager() }
        container.register(PlistManager.self) { r in PlistManager() }
        container.register(CapabilityManager.self) { r in CapabilityManager() }
        container.register(BackupManager.self) { r in BackupManager() }
        container.register(LoggingService.self) { r in LoggingService() }
        
        container.register(PrivilegeEscalationManager.self) { r in PrivilegeEscalationManager.shared }
    }
    
    private func setupPrivilegeEscalation() {
        Task {
            do {
                try await PrivilegeEscalationManager.shared.initialize()
            } catch {
                print("[ERROR] Privilege escalation initialization failed: \(error)")
                // Continue with read-only mode
            }
        }
    }
    
    private func navigateToMainInterface() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        
        if let window = window {
            window.rootViewController = mainVC
        }
    }
}

extension HyperGestaltAppDelegate {
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .appWillResignActive, object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
    }
}
