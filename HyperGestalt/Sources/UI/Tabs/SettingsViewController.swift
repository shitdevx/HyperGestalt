import UIKit

class SettingsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let sections: [(title: String, items: [(String, String)])] = [
        ("App", [
            ("Version", "1.0.0 (build 1)"),
            ("Exploit Engine", "darksword-kexploit + bad_query + clipwire"),
            ("Jailbreak Requirement", "Required for all operations"),
        ]),
        ("Data", [
            ("Export Exploit Logs", "Save logs to Files app"),
            ("Export Configuration", "Share current config as .plist"),
            ("Clear Exploit Logs", "Delete all exploit failure logs"),
            ("Clear Configuration", "Reset all settings to defaults"),
        ]),
        ("Credits", [
            ("darksword-kexploit", "opa334 - Kernel exploit for iOS 15-26"),
            ("bad_query", "Sandbox escape PoC"),
            ("clipwire", "vm_map_clip wire OOB exploit"),
            ("HyperGestalt", "MobileGestalt & Capability Editor"),
        ]),
        ("Links", [
            ("Source Code", "github.com/shitdevx/HyperGestalt"),
            ("Report Issue", "github.com/shitdevx/HyperGestalt/issues"),
        ]),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground

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

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sections[section].title }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.0
        config.secondaryText = item.1
        config.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = config

        if sections[indexPath.section].title == "Links" {
            cell.accessoryType = .disclosureIndicator
            cell.tintColor = .systemBlue
        } else if sections[indexPath.section].title == "Data" {
            cell.accessoryType = .disclosureIndicator
            if item.0.contains("Clear") {
                cell.tintColor = .systemRed
            }
        } else {
            cell.selectionStyle = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]

        if item.0 == "Export Exploit Logs" || item.0 == "Export Configuration" {
            let alert = UIAlertController(title: "Export", message: "\(item.0) coming soon.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else if item.0 == "Clear Exploit Logs" {
            let alert = UIAlertController(title: "Clear Logs?", message: "This deletes all exploit failure logs.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
                print("[Settings] Cleared exploit logs")
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        } else if item.0 == "Clear Configuration" {
            let alert = UIAlertController(title: "Reset Configuration?", message: "All settings will be reset to defaults.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
                print("[Settings] Configuration reset")
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        } else if item.0 == "Source Code" || item.0 == "Report Issue" {
            if let url = URL(string: "https://\(item.1)") {
                UIApplication.shared.open(url)
            }
        }
    }
}
