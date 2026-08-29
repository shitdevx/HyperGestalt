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

                Section(header: Text("Tweaks • iOS \(osVersionString()) • \(machine_name())")) {
                    NavigationLink(destination: GestaltView()) {
                        HStack {
                            Text("MobileGestalt")
                            Spacer()
                            Text("\(all_tweaks.filter { $0.supported() }.count) tweaks")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .disabled(state.mg_granted != true)

                    NavigationLink(destination: CEView()) {
                        Text("CacheExtra Editor")
                    }
                    .disabled(state.mg_granted != true)

                    if state.mg_granted == true {
                        Button("Respring") { respring() }
                            .foregroundColor(.orange)
                    }
                }

                if !is_valid {
                    Section(header: Text("Safety")) {
                        Text("Plist invalid — Apply is blocked until valid file loaded. Revert or restore backup.")
                            .font(.caption).foregroundColor(.red)
                    }
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
