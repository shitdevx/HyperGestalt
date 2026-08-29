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

                Section(header: Text("Exploit")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(state.mg_granted == true ? "Access Granted" : state.mg_granted == false ? "Access Denied" : "Not Run")
                                .font(.headline)
                            Text(state.granting_mg ? "Running…" : "Tap to run sandbox escape")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if state.granting_mg {
                            ProgressView()
                        } else if let granted = state.mg_granted {
                            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(granted ? .green : .red)
                        }
                    }
                    Button(state.mg_granted == true ? "Re-run Exploit" : "Run Exploit") {
                        grant_all(state: state)
                    }
                    .disabled(state.granting_mg)
                }

                Section(header: Text("Tweaks")) {
                    NavigationLink(destination: GestaltView()) {
                        Text("MobileGestalt")
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
