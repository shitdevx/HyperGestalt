import Foundation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let splash = SplashScreenViewController()
        splash.onSplashComplete = { [weak self] in
            self?.window?.rootViewController = MainTabBarController()
        }
        window?.rootViewController = splash
        window?.makeKeyAndVisible()
    }
}
