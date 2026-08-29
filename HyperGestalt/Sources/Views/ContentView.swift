import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Logs")) {
                    LogView()
                        .frame(minHeight: 120)
                }

                Section(header: Text("Tweaks")) {
                    NavigationLink(destination: GestaltView()) {
                        HStack {
                            Text("MobileGestalt")
                            Spacer()
                            if state.granting_mg {
                                ProgressView()
                            } else if let granted = state.mg_granted {
                                Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(granted ? .green : .red)
                            }
                        }
                    }
                    .disabled(state.mg_granted != true)

                    NavigationLink(destination: CEView()) {
                        Text("CacheExtra Editor")
                    }
                    .disabled(state.mg_granted != true)
                }
            }
            .navigationTitle("HyperGestalt")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}
