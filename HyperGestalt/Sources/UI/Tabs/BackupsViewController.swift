import UIKit

class BackupsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var backups: [(name: String, date: String, model: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Backups"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(createBackup))

        loadBackups()

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

    private func loadBackups() {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("HyperGestalt/backups")
        if let contents = try? FileManager.default.contentsOfDirectory(at: base, includingPropertiesForKeys: nil) {
            backups = contents.filter { $0.pathExtension == "plist" }.map { url in
                let name = url.deletingPathExtension().lastPathComponent
                let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
                let date = attrs?[.creationDate] as? Date ?? Date()
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                return (name: name, date: formatter.string(from: date), model: "Unknown")
            }.sorted { $0.date > $1.date }
        }
    }

    @objc private func createBackup() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let name = "backup_\(formatter.string(from: Date()))"

        let alert = UIAlertController(title: "Create Backup", message: "Save current configuration as '\(name)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("HyperGestalt/backups")
            try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
            let url = base.appendingPathComponent("\(name).plist")
            let data: [String: String] = [
                "deviceModel": UIDevice.current.model,
                "systemVersion": UIDevice.current.systemVersion,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
            if let plistData = try? PropertyListSerialization.data(fromPropertyList: data, format: .xml, options: 0) {
                try? plistData.write(to: url)
            }
            self?.loadBackups()
            self?.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension BackupsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        backups.isEmpty ? "No backups yet" : "Saved Backups"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(backups.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if backups.isEmpty {
            var config = cell.defaultContentConfiguration()
            config.text = "No Backups"
            config.secondaryText = "Tap + to create your first backup"
            cell.contentConfiguration = config
            cell.selectionStyle = .none
        } else {
            let backup = backups[indexPath.row]
            var config = cell.defaultContentConfiguration()
            config.text = backup.name
            config.secondaryText = backup.date
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !backups.isEmpty else { return }
        let backup = backups[indexPath.row]

        let alert = UIAlertController(title: backup.name, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Restore", style: .default) { _ in
            print("[Backups] Restore: \(backup.name)")
        })
        alert.addAction(UIAlertAction(title: "Export", style: .default) { _ in
            print("[Backups] Export: \(backup.name)")
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("HyperGestalt/backups")
            let url = base.appendingPathComponent("\(backup.name).plist")
            try? FileManager.default.removeItem(at: url)
            self?.loadBackups()
            self?.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !backups.isEmpty else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            let backup = self!.backups[indexPath.row]
            let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("HyperGestalt/backups")
            let url = base.appendingPathComponent("\(backup.name).plist")
            try? FileManager.default.removeItem(at: url)
            self?.loadBackups()
            self?.tableView.reloadData()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
