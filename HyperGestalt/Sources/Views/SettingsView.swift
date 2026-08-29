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
                        Text("v1.0.0 - MobileGestalt Editor")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section(header: Text("Exploit")) {
                Button("Re-run Exploit") {
                    grant_all(state: state)
                }
            }

            Section(header: Text("Write Mode")) {
                Toggle("Atomic Write", isOn: $atomic_write)
            }

            Section(header: Text("Credits")) {
                ForEach(credits, id: \.name) { credit in
                    Button(action: {
                        if let url = URL(string: credit.url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(credit.name).font(.headline)
                                Text(credit.role).font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .imageScale(.small)
                        }
                    }
                    .foregroundColor(.primary)
                }
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
