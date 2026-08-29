import Foundation
import UIKit

@MainActor
class HyperGestaltAppDelegate: NSObject, UIApplicationDelegate {
    static let shared = HyperGestaltAppDelegate()
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        setupPrivilegeEscalation()
        let splashScreen = SplashScreenViewController()
        splashScreen.onSplashComplete = { [weak self] in
            self?.navigateToMainInterface()
        }
        window?.rootViewController = splashScreen
        window?.makeKeyAndVisible()
        return true
    }
    
    private func setupPrivilegeEscalation() {
        Task {
            do {
                try await PrivilegeEscalationManager.shared.initialize()
            } catch {
                print("[ERROR] Privilege escalation failed: \(error)")
            }
        }
    }
    
    private func navigateToMainInterface() {
        let mainVC = MainTabBarController()
        window?.rootViewController = mainVC
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

extension Notification {
    static let appWillResignActive = Notification.Name("appWillResignActive")
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
}
