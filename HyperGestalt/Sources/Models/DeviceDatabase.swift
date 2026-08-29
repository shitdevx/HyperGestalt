import Foundation
import UIKit

class DeviceDatabase: ObservableObject {
    @Published var devices: [DeviceModel] = []
    @Published var isLoading: Bool = false
    static let shared = DeviceDatabase()
    private init() { loadDeviceDatabase() }
    func getDevice(_ id: String) -> DeviceModel? { devices.first { $0.modelIdentifier == id } }
    func searchDevices(query: String) -> [DeviceModel] {
        guard !query.isEmpty else { return devices }
        let q = query.lowercased()
        return devices.filter { $0.marketingName.lowercased().contains(q) || $0.modelIdentifier.lowercased().contains(q) }
    }
    private func loadDeviceDatabase() {
        isLoading = true
        devices = [
            DeviceModel(modelIdentifier: "iPad9,1", marketingName: "iPad 9th Gen", category: .ipad, releaseYear: 2021),
            DeviceModel(modelIdentifier: "iPhone17,1", marketingName: "iPhone 17 Pro", category: .iphone, releaseYear: 2025),
            DeviceModel(modelIdentifier: "iPhone17,2", marketingName: "iPhone 17 Pro Max", category: .iphone, releaseYear: 2025),
            DeviceModel(modelIdentifier: "iPhone12,1", marketingName: "iPhone 11", category: .iphone, releaseYear: 2019),
        ]
        isLoading = false
    }
}

struct DeviceModel: Codable, Identifiable {
    var id = UUID()
    let modelIdentifier: String
    let marketingName: String
    let category: DeviceCategory
    let releaseYear: Int
    var displayName: String { "\(marketingName) (\(modelIdentifier))" }
    enum DeviceCategory: String, CaseIterable, Codable { case iphone, ipad, ipod, appleTv, homepod }
}
