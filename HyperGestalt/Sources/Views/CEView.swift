import SwiftUI

struct CEView: View {
    @EnvironmentObject var state: AppState
    @State private var search = ""
    @State private var editing_key: String?
    @State private var showing_add = false

    private var keys: [String] {
        let cache = mg_dict_now["CacheExtra"] as? [String: Any] ?? [:]
        let all = cache.keys.sorted()
        guard !search.isEmpty else { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(search) }
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
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(ce_summary(cache[key]))
                                    .font(.system(.caption, design: .monospaced))
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
        .navigationTitle("CacheExtra")
        .onAppear { mg_load() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button { showing_add = true } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        do {
                            let data = try PropertyListSerialization.data(fromPropertyList: mg_dict_now, format: .xml, options: 0)
                            try mg_write(data)
                            state.appendLog("[ce] saved changes")
                        } catch {
                            state.appendLog("[ce] save failed: \(error)")
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { editing_key != nil },
            set: { if !$0 { editing_key = nil } }
        )) {
            if let key = editing_key {
                CEEditSheet(key: key, onDismiss: { editing_key = nil })
            }
        }
        .sheet(isPresented: $showing_add) {
            CEAddSheet(onDismiss: { showing_add = false })
        }
    }
}

private struct CEEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let key: String
    var onDismiss: () -> Void
    @State private var text: String
    @State private var error: String?

    init(key: String, onDismiss: @escaping () -> Void) {
        self.key = key
        self.onDismiss = onDismiss
        let cache = mg_dict_now["CacheExtra"] as? [String: Any] ?? [:]
        _text = State(initialValue: ce_encode(cache[key]))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Key")) {
                    Text(key).font(.system(.body, design: .monospaced))
                }
                Section(header: Text("Value")) {
                    TextEditor(text: $text)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 120)
                }
                if let error {
                    Section { Text(error).foregroundColor(.red) }
                }
            }
            .navigationTitle(key)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onDismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                        cache[key] = ce_parse(text)
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
    @State private var error: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Key")) {
                    TextField("Key name", text: $key)
                        .font(.system(.body, design: .monospaced))
                }
                Section(header: Text("Value")) {
                    TextEditor(text: $value)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 100)
                }
                if let error {
                    Section { Text(error).foregroundColor(.red) }
                }
            }
            .navigationTitle("Add Field")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onDismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { error = "Key cannot be empty"; return }
                        guard (mg_dict_now["CacheExtra"] as? [String: Any])?[trimmed] == nil else { error = "Key exists"; return }
                        guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                        cache[trimmed] = ce_parse(value)
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

func ce_summary(_ value: Any?) -> String {
    switch value {
    case let s as String: return s.isEmpty ? "(empty)" : s
    case let n as NSNumber: return n.stringValue
    case let d as Data: return "Data (\(d.count) bytes)"
    default: return String(describing: value ?? "nil")
    }
}
