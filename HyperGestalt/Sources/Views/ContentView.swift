import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .frame(minHeight: 120)
                } header: {
                    Label("Logs", systemImage: "apple.terminal")
                }

                Section {
                    NavigationLink {
                        GestaltView()
                    } label: {
                        HStack {
                            Text("MobileGestalt")
                            Spacer()
                            if state.granting_mg {
                                ProgressView()
                            } else if let granted = state.mg_granted {
                                Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(granted ? .green : .red)
                            }
                        }
                    }
                    .disabled(state.mg_granted != true)

                    NavigationLink {
                        CEView()
                    } label: {
                        Text("CacheExtra Editor")
                    }
                    .disabled(state.mg_granted != true)
                } header: {
                    Label("Tweaks", systemImage: "paintbrush")
                } footer: {
                    Text("Requires jailbroken device with bad_query exploit support.")
                }
            }
            .navigationTitle("HyperGestalt")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}
