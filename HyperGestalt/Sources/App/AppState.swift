import SwiftUI

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var exploit_succeeded = false
    @Published var granting_mg = false
    @Published var mg_granted: Bool? = nil
    @Published var log_output = ""

    func appendLog(_ text: String) {
        DispatchQueue.main.async {
            self.log_output += text + "\n"
        }
    }
}
