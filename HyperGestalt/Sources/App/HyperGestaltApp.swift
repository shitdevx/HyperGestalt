import SwiftUI

@main
struct HyperGestaltApp: App {
    @StateObject private var state = AppState.shared

    init() {
        UserDefaults.standard.register(defaults: [
            "method": "bad_query",
            "atomic_write": true,
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .onAppear {
                    grant_all(state: state)
                }
        }
    }
}
