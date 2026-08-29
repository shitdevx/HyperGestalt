import SwiftUI

struct GestaltView: View {
    @EnvironmentObject var state: AppState

    @State private var selected_st: String = "og"
    @State private var enable_device_name: Bool = false
    @State private var mg_device_name: String = ""
    @State private var product_type: String = machine_name()
    @State private var selectedCategory: String = "All"
    @State private var showDiff = false
    @State private var showExport = false
    @State private var exportName = ""

    private var filteredTweaks: [mg_tweak] {
        all_tweaks.filter { t in
            guard t.supported() else { return false }
            if selectedCategory == "All" { return true }
            return t.category == selectedCategory
        }
    }

    private var grouped: [String: [mg_tweak]] {
        Dictionary(grouping: filteredTweaks, by: { $0.category })
    }

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
                    do {
                        try mg_apply()
                        state.appendLog("[mg] tweaks applied, respring for changes")
                        if let v = mg_verify_on_disk() { state.appendLog(v) }
                    } catch {
                        state.appendLog("[mg] apply failed: \(error.localizedDescription)")
                    }
                }
                .disabled(is_empty || !is_valid)
                Button("Revert Tweaks") {
                    do {
                        try mg_revert()
                        state.appendLog("[mg] reverted to original")
                    } catch {
                        state.appendLog("[mg] revert failed: \(error.localizedDescription)")
                    }
                }
                Button("Respring") { respring() }
                    .foregroundColor(.orange)
                Button("Show Diff vs Backup") { showDiff = true }
                Button("Export Preset") { showExport = true }
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

            Section(header: Text("Eligibility")) {
                Picker("Device Spoofing", selection: $product_type) {
                    Text("Default (\(machine_name()))").tag(machine_name())
                    Text("iPhone 15 Pro").tag("iPhone16,1")
                    Text("iPhone 15 Pro Max").tag("iPhone16,2")
                    if doubleSystemVersion() >= 18.0 {
                        Text("iPhone 16 Pro").tag("iPhone17,1")
                        Text("iPhone 16 Pro Max").tag("iPhone17,2")
                    }
                    Text("iPhone 17").tag("iPhone18,3")
                    Text("iPad Mini A17 Pro").tag("iPad16,1")
                    Text("iPad Pro M4 13\"").tag("iPad16,5")
                }
            }

            Section(header: Text("Filter")) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(tweakCategories, id: \.self) { c in Text(c).tag(c) }
                }
                .pickerStyle(.segmented)
                Text("\(filteredTweaks.count) tweaks • iOS \(osVersionString()) • \(machine_name())")
                    .font(.caption).foregroundColor(.secondary)
            }

            ForEach(grouped.keys.sorted(), id: \.self) { cat in
                Section(header: Text(cat)) {
                    ForEach(grouped[cat]!, id: \.title) { t in
                        TweakToggle(tweak: t)
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
        .sheet(isPresented: $showDiff) { DiffView() }
        .sheet(isPresented: $showExport) {
            NavigationView {
                Form {
                    TextField("Preset name", text: $exportName)
                    Button("Save") {
                        do {
                            let url = try mg_export_preset(name: exportName.isEmpty ? "preset-\(Int(Date().timeIntervalSince1970))" : exportName)
                            state.appendLog("[preset] saved to \(url.lastPathComponent)")
                            showExport = false
                        } catch {
                            state.appendLog("[preset] save failed: \(error.localizedDescription)")
                        }
                    }
                }
                .navigationTitle("Export Preset")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showExport = false } } }
            }
        }
    }
}

struct DiffView: View {
    var body: some View {
        NavigationView {
            List {
                let d = mg_diff()
                if d.isEmpty {
                    Text("No changes vs backup").foregroundColor(.secondary)
                } else {
                    ForEach(d, id: \.key) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.key).font(.system(.caption, design: .monospaced)).foregroundColor(.primary)
                            Text("was: \(String(describing: item.old ?? "nil"))").font(.caption2).foregroundColor(.red)
                            Text("now: \(String(describing: item.new ?? "nil"))").font(.caption2).foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Diff")
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
