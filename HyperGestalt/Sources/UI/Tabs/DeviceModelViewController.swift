import UIKit

class DeviceModelViewController: UIViewController, UISearchResultsUpdating {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private var allDevices: [DeviceModel] = []
    private var filteredDevices: [DeviceModel] = []
    private var selectedModel: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Device Model"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(applySelection))

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search devices..."
        navigationItem.searchController = searchController
        definesPresentationContext = true

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

        allDevices = DeviceDatabase.shared.devices
        filteredDevices = allDevices
        selectedModel = UIDevice.current.modelName
    }

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.lowercased() ?? ""
        filteredDevices = query.isEmpty ? allDevices : allDevices.filter {
            $0.marketingName.lowercased().contains(query) || $0.modelIdentifier.lowercased().contains(query)
        }
        tableView.reloadData()
    }

    @objc private func applySelection() {
        guard let model = selectedModel else { return }
        let alert = UIAlertController(
            title: "Apply Model Spoof",
            message: "Set device model to \(model)? This writes to the MobileGestalt cache.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Apply", style: .destructive) { _ in
            print("[DeviceModel] Selected: \(model)")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension DeviceModelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let device = filteredDevices[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = device.marketingName
        config.secondaryText = device.modelIdentifier
        cell.contentConfiguration = config
        cell.accessoryType = device.modelIdentifier == selectedModel ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedModel = filteredDevices[indexPath.row].modelIdentifier
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }
}

private extension UIDevice {
    var modelName: String {
        var uts = utsname()
        uname(&uts)
        return withUnsafePointer(to: &uts.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 256) { String(cString: $0) }
        }
    }
}
