import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @AppStorage("method") private var method: String = "bad_query"
    @AppStorage("atomic_write") private var atomic_write = true

    var body: some View {
        List {
            Section {
                HStack {
                    if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
                       let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
                       let files = primary["CFBundleIconFiles"] as? [String],
                       let icon = files.last,
                       let img = UIImage(named: icon) {
                        Image(uiImage: img)
                            .resizable()
                            .frame(width: 45, height: 45)
                            .cornerRadius(12)
                    }
                    VStack(alignment: .leading) {
                        Text("HyperGestalt")
                            .font(.headline)
                        Text("v1.0.0 - MobileGestalt & Capability Editor")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Picker("Method", selection: $method) {
                    Text("bad_query").tag("bad_query")
                }
                .pickerStyle(.segmented)

                Button("Re-run Exploit") {
                    grant_all(state: state)
                }
            } header: {
                Label("Exploit", systemImage: "wrench.and.screwdriver")
            } footer: {
                Text("**bad_query:** Sandbox escape via containermanager. Supports iOS 15.0+. By forcequit.")
            }

            Section {
                Toggle("Atomic Write", isOn: $atomic_write)
            } header: {
                Label("Write Mode", systemImage: "internaldrive")
            } footer: {
                Text("Atomic write replaces the file. Disable for in-place write which may persist across reboots.")
            }

            Section {
                Button("Respring") {
                    // Respring via notification crash
                    let url = URL(string: "prefs:root=General")!
                    UIApplication.shared.open(url)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
            } header: {
                Label("Tools", systemImage: "wrench.and.screwdriver")
            }

            Section {
                HStack {
                    Text("Credits")
                        .font(.headline)
                }
                ForEach(credits, id: \.name) { credit in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(credit.name).font(.headline)
                            Text(credit.role).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .imageScale(.small)
                    }
                    .onTapGesture {
                        if let url = URL(string: credit.url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            } header: {
                Label("Credits", systemImage: "person.3.fill")
            }
        }
        .navigationTitle("Settings")
    }

    private let credits: [(name: String, role: String, url: String)] = [
        ("forcequit", "bad_query sandbox escape", "https://github.com/forcequitOS"),
        ("opa334", "darksword kernel exploit", "https://github.com/opa334/darksword-kexploit"),
        ("roooot", "mond (reference app)", "https://github.com/rooootdev/mond"),
    ]
}
