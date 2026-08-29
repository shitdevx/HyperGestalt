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
                Section(header: Text("Warning")) {
                    if is_empty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow)
                            Text("MobileGestalt.plist is empty. Do not reboot!")
                        }
                    }
                    if !is_valid {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow)
                            Text("MobileGestalt.plist is invalid. Do not reboot!")
                        }
                    }
                }
            }

            Section {
                Button("Apply Tweaks") {
                    mg_apply()
                    state.appendLog("[mg] tweaks applied, respring for changes")
                }
                Button("Revert Tweaks") {
                    mg_revert()
                    state.appendLog("[mg] reverted to original")
                }
            }

            Section(header: Text("Device Artwork")) {
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
            }

            Section(header: Text("Features")) {
                ForEach(Array(all_tweaks.enumerated()), id: \.element.title) { _, t in
                    if t.supported() {
                        TweakToggle(tweak: t)
                    }
                }
            }

            Section(header: Text("Eligibility")) {
                Picker("Device Spoofing", selection: $product_type) {
                    Text("Default (\(machine_name()))").tag(machine_name())
                    Text("iPhone 15 Pro").tag("iPhone16,1")
                    Text("iPhone 15 Pro Max").tag("iPhone16,2")
                    if doubleSystemVersion() >= 18.0 {
                        Text("iPhone 16 Pro").tag("iPhone17,1")
                        Text("iPhone 16 Pro Max").tag("iPhone17,2")
                    }
                }
            }
        }
        .navigationTitle("MobileGestalt")
        .onAppear {
            mg_load()
            DispatchQueue.global().async {
                while is_loading { Thread.sleep(forTimeInterval: 0.05) }
                DispatchQueue.main.async {
                    selected_st = selected_st
                    enable_device_name = enable_device_name
                    mg_device_name = mg_device_name
                    product_type = product_type
                }
            }
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
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
