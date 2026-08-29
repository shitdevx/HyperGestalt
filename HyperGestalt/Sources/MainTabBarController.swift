import UIKit
import Foundation

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize tab bar controller with custom appearance
        tabBar.tintColor = UIColor.systemBlue
        tabBar.backgroundColor = UIColor.systemBackground
        
        setupTabs()
    }
    
    private func setupTabs() {
        let dashboardVC = DashboardViewController()
        let deviceModelVC = DeviceModelViewController()
        let featuresVC = FeaturesViewController()
        let advancedVC = AdvancedViewController()
        let backupsVC = BackupsViewController()
        let settingsVC = SettingsViewController()
        
        viewControllers = [
            createNavController(for: dashboardVC, title: "Dashboard", image: "house.fill"),
            createNavController(for: deviceModelVC, title: "Device Model", image: "iphone"),
            createNavController(for: featuresVC, title: "Features", image: "star.fill"),
            createNavController(for: advancedVC, title: "Advanced", image: "gearshape"),
            createNavController(for: backupsVC, title: "Backups", image: "arrow.counterclockwise"),
            createNavController(for: settingsVC, title: "Settings", image: "gear"),
        ]
    }
    
    private func createNavController(for viewController: UIViewController, title: String, image: String) -> UINavigationController {
        viewController.title = title
        let navController = UINavigationController(rootViewController: viewController)
        let tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: image), selectedImage: UIImage(systemName: "\(image).fill"))
        navController.tabBarItem = tabBarItem
        return navController
    }
}