import SwiftUI

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var exploit_succeeded = false
    @Published var granting_mg = false
    @Published var mg_granted: Bool? = nil
    @Published var log_output = ""

    func appendLog(_ text: String) {
        if Thread.isMainThread {
            self.log_output += text + "\n"
        } else {
            DispatchQueue.main.async {
                self.log_output += text + "\n"
            }
        }
    }
}
