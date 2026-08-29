import UIKit

class FeaturesViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var sections: [(title: String, features: [(key: String, label: String, enabled: Bool)])] = []

    private let commonFeatures: [(String, String)] = [
        ("VoiceOver", "com.apple.convergence.voiceover"),
        ("Switch Control", "com.apple.convergence.switchcontrol"),
        ("Zoom", "com.apple.convergence.zoom"),
        ("AssistiveTouch", "com.apple.convergence.assistivetouch"),
        ("Bold Text", "UIAccessibilityIsBoldTextEnabled"),
        ("Reduce Motion", "UIAccessibilityIsReduceMotionEnabled"),
        ("Dark Mode", "UIInterfaceStyle"),
        ("Cellular Data", "allowCellularData"),
        ("NFC", "com.apple.security.nfc.allow-read"),
        ("Apple Pay", "com.apple.security.apple-pay"),
        ("Camera", "com.apple.security.camera"),
        ("Microphone", "com.apple.security.microphone"),
        ("Location Services", "com.apple.locationd"),
        ("Bluetooth", "com.apple.Bluetooth"),
        ("Wi-Fi", "com.apple.wifi"),
    ]

    private let mgKeys: [(String, String)] = [
        ("ProductType", "ProductType"),
        ("DeviceClass", "DeviceClass"),
        ("HWModelStr", "HWModelStr"),
        ("CPUArchitecture", "CPUArchitecture"),
        ("BuildVersion", "BuildVersion"),
        ("ProductVersion", "ProductVersion"),
        ("ReleaseType", "ReleaseType"),
        ("DeviceName", "DeviceName"),
        ("UserAssignedDeviceName", "UserAssignedDeviceName"),
        ("RegionCode", "RegionCode"),
        ("RegionInfo", "RegionInfo"),
        ("AirplaneMode", "AirplaneMode"),
        ("AllowYouTube", "AllowYouTube"),
        ("AllowYouTubePlugin", "AllowYouTubePlugin"),
        ("MinimumSupportediTunesVersion", "MinimumSupportediTunesVersion"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Features"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Apply", style: .done, target: self, action: #selector(applyFeatures))

        sections = [
            ("Accessibility", commonFeatures.prefix(6).map { (key: $0.1, label: $0.0, enabled: false) }),
            ("Hardware", commonFeatures.dropFirst(6).map { (key: $0.1, label: $0.0, enabled: false) }),
            ("MobileGestalt Keys", mgKeys.map { (key: $0.1, label: $0.0, enabled: false) }),
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

    @objc private func applyFeatures() {
        let alert = UIAlertController(
            title: "Apply Features",
            message: "Feature overrides will be written to the MobileGestalt plist on next exploit run.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension FeaturesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sections[section].title }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].features.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let feature = sections[indexPath.section].features[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = feature.label
        config.secondaryText = feature.key
        cell.contentConfiguration = config

        let toggle = UISwitch()
        toggle.isOn = feature.enabled
        toggle.tag = indexPath.section * 1000 + indexPath.row
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle
        cell.selectionStyle = .none
        return cell
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        let section = sender.tag / 1000
        let row = sender.tag % 1000
        sections[section].features[row].enabled = sender.isOn
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
