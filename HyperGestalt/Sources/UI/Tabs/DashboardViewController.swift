import UIKit

class DashboardViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var deviceInfo: [(String, [(String, String)])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dashboard"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: nil, action: nil)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDeviceData()
        tableView.reloadData()
    }

    private func reloadDeviceData() {
        var uts = utsname()
        uname(&uts)
        let machine = withUnsafePointer(to: &uts.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 256) { String(cString: $0) }
        }
        let version = UIDevice.current.systemVersion
        let major = Int(version.split(separator: ".").first.map(String.init) ?? "0") ?? 0

        let exploitStatus: String
        if major == 15 || (major >= 16 && major <= 18) || (major == 26) {
            exploitStatus = "darksword-kexploit available"
        } else if major >= 26 {
            exploitStatus = "bad_query / clipwire fallback"
        } else {
            exploitStatus = "Not in supported range"
        }

        let jailbroken = FileManager.default.fileExists(atPath: "/var/mobile/Library/Cydia")
            || FileManager.default.fileExists(atPath: "/var/lib/apt")
            || FileManager.default.fileExists(atPath: "/var/jb")

        deviceInfo = [
            ("Device", [
                ("Model Identifier", machine),
                ("System Version", "iOS \(version)"),
                ("Jailbreak", jailbroken ? "Detected" : "Not detected"),
            ]),
            ("Exploit Chain", [
                ("Status", exploitStatus),
                ("darksword-kexploit", "iOS 15.0 - 26.0.1"),
                ("bad_query", "iOS 26.0 - 27.0b4"),
                ("clipwire", "iOS 26.1, iPhone11,1 (A13)"),
            ]),
            ("Quick Actions", [
                ("Apply Configuration", "Write spoofed MG plist"),
                ("View Logs", "Exploit failure logs"),
                ("Refresh", "Re-detect device info"),
            ]),
        ]
    }
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { deviceInfo.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { deviceInfo[section].0 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deviceInfo[section].1.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = deviceInfo[indexPath.section].1[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.0
        config.secondaryText = item.1
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
