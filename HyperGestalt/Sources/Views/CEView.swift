import SwiftUI

struct CEView: View {
    @EnvironmentObject var state: AppState
    @State private var search = ""
    @State private var editing_key: String?
    @State private var showing_add = false
    @State private var selectedType = 0 // 0=int 1=bool 2=string 3=data
    @State private var importPresets = false

    private var keys: [String] {
        let cache = mg_dict_now["CacheExtra"] as? [String: Any] ?? [:]
        let all = cache.keys.sorted()
        guard !search.isEmpty else { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(search) || String(describing: cache[$0] ?? "").localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        List {
            if keys.isEmpty {
                Text(search.isEmpty ? "No CacheExtra fields" : "No results")
                    .foregroundColor(.secondary)
            } else {
                ForEach(keys, id: \.self) { key in
                    let cache = mg_dict_now["CacheExtra"] as? [String: Any] ?? [:]
                    Button { editing_key = key } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(key)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text("\(ce_type_label(cache[key])) • \(ce_summary(cache[key]))")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete { offsets in
                    guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                    let sorted = keys
                    for i in offsets { cache.removeObject(forKey: sorted[i]) }
                    mg_dict_now["CacheExtra"] = cache
                }
            }
        }
        .searchable(text: $search, prompt: "Search keys or values")
        .navigationTitle("CacheExtra (\(keys.count))")
        .onAppear { mg_load() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Menu {
                        Button("Import Preset") { importPresets = true }
                        Button("Export Current as Preset") {
                            do {
                                let url = try mg_export_preset(name: "export-\(Int(Date().timeIntervalSince1970))")
                                state.appendLog("[preset] exported \(url.lastPathComponent)")
                            } catch { state.appendLog("[preset] export failed \(error)") }
                        }
                    } label: { Image(systemName: "square.and.arrow.down") }

                    Button { showing_add = true } label: { Image(systemName: "plus") }

                    Button {
                        do {
                            let data = try PropertyListSerialization.data(fromPropertyList: mg_dict_now, format: .xml, options: 0)
                            try mg_write(data)
                            state.appendLog("[ce] saved changes")
                            if let v = mg_verify_on_disk() { state.appendLog(v) }
                        } catch {
                            state.appendLog("[ce] save failed: \(error.localizedDescription)")
                        }
                    } label: { Image(systemName: "checkmark") }
                }
            }
        }
        .sheet(isPresented: Binding(get: { editing_key != nil }, set: { if !$0 { editing_key = nil } })) {
            if let key = editing_key { CEEditSheet(key: key, onDismiss: { editing_key = nil }) }
        }
        .sheet(isPresented: $showing_add) { CEAddSheet(onDismiss: { showing_add = false }) }
        .sheet(isPresented: $importPresets) { PresetListView() }
    }
}

private struct PresetListView: View {
    @EnvironmentObject var state: AppState
    @State private var files: [URL] = []

    var body: some View {
        NavigationView {
            List {
                if files.isEmpty {
                    Text("No presets in Documents/HyperGestaltPresets").foregroundColor(.secondary)
                } else {
                    ForEach(files, id: \.lastPathComponent) { url in
                        Button(url.lastPathComponent) {
                            do {
                                try mg_import_preset(at: url)
                                state.appendLog("[preset] imported \(url.lastPathComponent)")
                            } catch { state.appendLog("[preset] import failed \(error)") }
                        }
                    }
                    .onDelete { idx in
                        for i in idx { try? FileManager.default.removeItem(at: files[i]) }
                        files = (try? FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: TweakPaths.presets), includingPropertiesForKeys: nil)) ?? []
                    }
                }
            }
            .navigationTitle("Presets")
            .onAppear {
                files = (try? FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: TweakPaths.presets), includingPropertiesForKeys: nil)) ?? []
            }
        }
    }
}

private struct CEEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let key: String
    var onDismiss: () -> Void
    @State private var text: String
    @State private var selectedType: Int
    @State private var error: String?

    init(key: String, onDismiss: @escaping () -> Void) {
        self.key = key
        self.onDismiss = onDismiss
        let cache = mg_dict_now["CacheExtra"] as? [String: Any] ?? [:]
        let val = cache[key]
        _text = State(initialValue: ce_encode(val))
        if val is String { _selectedType = State(initialValue: 2) }
        else if val is Data { _selectedType = State(initialValue: 3) }
        else if let n = val as? NSNumber, String(cString: n.objCType) == "c" { _selectedType = State(initialValue: 1) }
        else { _selectedType = State(initialValue: 0) }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Key")) { Text(key).font(.system(.body, design: .monospaced)) }
                Section(header: Text("Type")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Int").tag(0); Text("Bool").tag(1); Text("String").tag(2); Text("Data (base64)").tag(3)
                    }.pickerStyle(.segmented)
                }
                Section(header: Text("Value")) {
                    if selectedType == 1 {
                        Picker("Bool", selection: $text) { Text("true").tag("true"); Text("false").tag("false") }.pickerStyle(.segmented)
                    } else {
                        TextEditor(text: $text).font(.system(.body, design: .monospaced)).frame(minHeight: 120)
                    }
                }
                if let error { Section { Text(error).foregroundColor(.red) } }
            }
            .navigationTitle(key)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { onDismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                        cache[key] = ce_parse_typed(text, type: selectedType)
                        mg_dict_now["CacheExtra"] = cache
                        onDismiss()
                    }.font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}

private struct CEAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: () -> Void
    @State private var key = ""
    @State private var value = ""
    @State private var type = 0
    @State private var error: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Key")) { TextField("Key name", text: $key).font(.system(.body, design: .monospaced)).autocapitalization(.none).disableAutocorrection(true) }
                Section(header: Text("Type")) { Picker("Type", selection: $type) { Text("Int").tag(0); Text("Bool").tag(1); Text("String").tag(2); Text("Data").tag(3) }.pickerStyle(.segmented) }
                Section(header: Text("Value")) {
                    if type == 1 { Picker("Bool", selection: $value) { Text("true").tag("true"); Text("false").tag("false") }.pickerStyle(.segmented).onAppear { if value.isEmpty { value = "true" } } }
                    else { TextEditor(text: $value).font(.system(.body, design: .monospaced)).frame(minHeight: 100) }
                }
                if let error { Section { Text(error).foregroundColor(.red) } }
            }
            .navigationTitle("Add Field")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { onDismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { error = "Key cannot be empty"; return }
                        guard (mg_dict_now["CacheExtra"] as? [String: Any])?[trimmed] == nil else { error = "Key exists"; return }
                        guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                        cache[trimmed] = ce_parse_typed(value, type: type)
                        mg_dict_now["CacheExtra"] = cache
                        onDismiss()
                    }.font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}

func ce_encode(_ value: Any?) -> String {
    switch value {
    case let s as String: return s
    case let n as NSNumber: return n.stringValue
    case let d as Data: return d.base64EncodedString()
    case let a as [Any]: return (try? String(data: JSONSerialization.data(withJSONObject: a), encoding: .utf8)) ?? "\(a)"
    default: return String(describing: value ?? "")
    }
}

func ce_parse(_ text: String) -> Any {
    let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if let v = Int64(t) { return NSNumber(value: v) }
    if t.lowercased() == "true" { return NSNumber(value: true) }
    if t.lowercased() == "false" { return NSNumber(value: false) }
    if let d = Data(base64Encoded: t) { return d }
    return t
}

func ce_parse_typed(_ text: String, type: Int) -> Any {
    let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
    switch type {
    case 0: if let v = Int64(t) { return NSNumber(value: v) }; return NSNumber(value: 0)
    case 1: return NSNumber(value: t.lowercased() == "true")
    case 3: if let d = Data(base64Encoded: t) { return d }; return Data()
    default: return t
    }
}

func ce_type_label(_ value: Any?) -> String {
    switch value {
    case is String: return "String"
    case let n as NSNumber: return String(cString: n.objCType) == "c" ? "Bool" : "Int"
    case is Data: return "Data"
    case is [Any]: return "Array"
    case is NSDictionary: return "Dict"
    default: return "Unknown"
    }
}

func ce_summary(_ value: Any?) -> String {
    switch value {
    case let s as String: return s.isEmpty ? "(empty)" : s
    case let n as NSNumber: return n.stringValue
    case let d as Data: return "Data (\(d.count) bytes)"
    case let a as [Any]: return "Array[\(a.count)]"
    default: return String(describing: value ?? "nil")
    }
}
