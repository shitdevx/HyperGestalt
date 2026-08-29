import UIKit

class AdvancedViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var sections: [(String, [(String, String)])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advanced"
        view.backgroundColor = .systemBackground

        sections = [
            ("MobileGestalt Cache Path", [
                ("Primary", "/var/mobile/Library/Preferences/com.apple.MobileGestalt.plist"),
                ("Cache", "/var/mobile/Containers/Shared/AppGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"),
                ("System", "/var/mobile/Library/Caches/com.apple.MobileGestalt.plist"),
            ]),
            ("Custom Keys", [
                ("Add Key", "Tap to add a custom MG key-value pair"),
                ("Raw Plist Editor", "Edit the plist as raw XML"),
                ("Import from file", "Load a .plist file from disk"),
                ("Export current", "Save current config to file"),
            ]),
            ("Exploit Settings", [
                ("Force exploit", "Skip checks, attempt exploit chain"),
                ("Verbose logging", "Enable detailed exploit logs"),
                ("Reset logs", "Clear exploit failure log archive"),
            ]),
            ("Danger Zone", [
                ("Restore original MG", "Revert all spoofing to stock"),
                ("Clear all overrides", "Delete all saved configurations"),
            ]),
        ]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension AdvancedViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sections[section].0 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].1.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = sections[indexPath.section].1[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.0
        config.secondaryText = item.1
        config.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = config

        if indexPath.section == 3 {
            cell.tintColor = .systemRed
        }

        if item.0 == "Verbose logging" || item.0 == "Force exploit" {
            let toggle = UISwitch()
            toggle.isOn = false
            cell.accessoryView = toggle
            cell.selectionStyle = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].1[indexPath.row]

        if item.0 == "Add Key" {
            let alert = UIAlertController(title: "Add Custom Key", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "Key name" }
            alert.addTextField { $0.placeholder = "Value" }
            alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
                let key = alert.textFields?[0].text ?? ""
                let val = alert.textFields?[1].text ?? ""
                print("[Advanced] Custom key: \(key) = \(val)")
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        } else if item.0 == "Danger Zone" || item.0 == "Restore original MG" {
            let alert = UIAlertController(
                title: "Restore Original",
                message: "This will revert all MobileGestalt overrides to stock values. Continue?",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Restore", style: .destructive) { _ in
                print("[Advanced] Restoring original MG")
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
}
