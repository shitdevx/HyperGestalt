import SwiftUI

struct GestaltView: View {
    @EnvironmentObject var state: AppState

    @State private var selected_st: String = "og"
    @State private var enable_device_name: Bool = false
    @State private var mg_device_name: String = ""
    @State private var product_type: String = machine_name()

    var body: some View {
        List {
            if !is_valid || is_empty {
                Section {
                    if is_empty {
                        warningRow("MobileGestalt.plist is empty. Do not reboot!")
                    }
                    if !is_valid {
                        warningRow("MobileGestalt.plist is invalid. Do not reboot!")
                    }
                } header: {
                    Label("Warning", systemImage: "exclamationmark.triangle")
                } footer: {
                    Text("Try 'Revert Tweaks'. If warnings persist, you may have a problem.")
                }
            }

            Section {
                Button("Apply Tweaks") {
                    selected_st = selected_st
                    product_type = product_type
                    mg_apply()
                    state.appendLog("[mg] tweaks applied, respring for changes")
                }
                Button("Revert Tweaks") {
                    mg_revert()
                    state.appendLog("[mg] reverted to original")
                }
            } footer: {
                Text("Changes require a respring to take effect.")
            }

            Section {
                Picker("Subtype", selection: $selected_st) {
                    Text("Original (\(og_st))").tag("og")
                    Text("Disable Dynamic Island").tag("no_dynamic_island")
                    Text("iPhone 14 Pro").tag("14p")
                    Text("iPhone 14 Pro Max").tag("14pm")
                    Text("iPhone 15 Pro Max").tag("15pm")
                    if doubleSystemVersion() >= 18.0 {
                        Text("iPhone 16 Pro").tag("16p")
                        Text("iPhone 16 Pro Max").tag("16pm")
                    }
                    if doubleSystemVersion() >= 26.0 {
                        Text("iPhone Air").tag("air")
                    }
                }

                Toggle("Custom Device Name", isOn: $enable_device_name)
                if enable_device_name {
                    TextField("Device Name", text: $mg_device_name)
                }
            } header: {
                Label("Device Artwork", systemImage: "paintbrush.pointed")
            }

            Section {
                ForEach(Array(all_tweaks.enumerated()), id: \.element.title) { idx, t in
                    if t.supported() {
                        TweakToggle(tweak: t)
                    }
                }
            } header: {
                Label("Features", systemImage: "gearshape")
            }

            Section {
                Picker("Device Spoofing", selection: $product_type) {
                    Text("Default (\(machine_name()))").tag(machine_name())
                    Text("iPhone 15 Pro").tag("iPhone16,1")
                    Text("iPhone 15 Pro Max").tag("iPhone16,2")
                    if doubleSystemVersion() >= 18.0 {
                        Text("iPhone 16 Pro").tag("iPhone17,1")
                        Text("iPhone 16 Pro Max").tag("iPhone17,2")
                    }
                }
            } header: {
                Label("Eligibility", systemImage: "checklist")
            }
        }
        .navigationTitle("MobileGestalt")
        .task {
            mg_load()
            while is_loading { try? await Task.sleep(for: .milliseconds(50)) }
            selected_st = selected_st
            enable_device_name = enable_device_name
            mg_device_name = mg_device_name
            product_type = product_type
        }
    }

    private func warningRow(_ text: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(text)
        }
    }
}

struct TweakToggle: View {
    let tweak: mg_tweak

    var body: some View {
        Toggle(isOn: mg_tweak_binding(tweak)) {
            VStack(alignment: .leading) {
                Text(tweak.title)
                if let msg = tweak.info_msg {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
