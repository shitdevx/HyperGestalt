import Foundation
import UIKit

enum TweakPaths {
    static var gestalt = "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    static var gestalt_dir = "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/"
    static var backups: String {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("backups", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url.path
    }
}

var mg_dict_now: NSMutableDictionary = NSMutableDictionary()
var is_loading = false
var is_valid = true
var is_empty = false
var og_st: Int = 0
var selected_st: String = "og"
var enable_device_name = false
var mg_device_name = ""
var product_type: String = machine_name()

var selected_st_value: Int {
    switch selected_st {
    case "no_dynamic_island": return 0
    case "14p": return 2436
    case "14pm": return 2796
    case "15pm": return 2976
    case "16p": return 2622
    case "16pm": return 2868
    case "air": return 2736
    case "x": return 2436
    default: return og_st
    }
}

func mg_load() {
    guard !is_loading, mg_dict_now.count == 0 else { return }
    is_loading = true

    let mg_url = URL(fileURLWithPath: TweakPaths.gestalt)

    DispatchQueue.global(qos: .userInitiated).async {
        do {
            let file_size = (try? FileManager.default.attributesOfItem(atPath: mg_url.path))?[.size] as? UInt64 ?? 0
            let loaded = try NSMutableDictionary(contentsOf: mg_url, error: ())

            let saved_url = URL(fileURLWithPath: TweakPaths.backups).appendingPathComponent("SavedGestalt.plist")
            if !FileManager.default.fileExists(atPath: saved_url.path) {
                try? FileManager.default.copyItem(at: mg_url, to: saved_url)
            }

            let saved = try? NSMutableDictionary(contentsOf: saved_url, error: ())
            let og_cache_extra = saved?["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let og_artwork = og_cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()

            let new_og_st = og_artwork["ArtworkDeviceSubType"] as? Int ?? 0
            let new_og_device_name = og_artwork["ArtworkDeviceProductDescription"] as? String ?? ""

            let cache_extra = loaded["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let artwork = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()

            let new_selected_st: String
            let subtype = artwork["ArtworkDeviceSubType"] as? Int ?? new_og_st
            switch subtype {
            case 0: new_selected_st = "no_dynamic_island"
            case 2436: new_selected_st = "14p"
            case 2796: new_selected_st = "14pm"
            case 2976: new_selected_st = "15pm"
            case 2622: new_selected_st = "16p"
            case 2868: new_selected_st = "16pm"
            case 2736: new_selected_st = "air"
            default: new_selected_st = "og"
            }

            let new_device_name = artwork["ArtworkDeviceProductDescription"] as? String ?? new_og_device_name
            let new_product_type = cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String ?? machine_name()

            DispatchQueue.main.async {
                mg_dict_now = loaded
                og_st = new_og_st
                selected_st = new_selected_st
                mg_device_name = new_device_name
                enable_device_name = (new_device_name != new_og_device_name)
                product_type = new_product_type
                is_valid = true
                is_empty = file_size == 0
                is_loading = false
            }
        } catch {
            DispatchQueue.main.async {
                print("[mg] failed to load: \(error)")
                is_valid = false
                is_empty = (try? FileManager.default.attributesOfItem(atPath: mg_url.path))?[.size] as? UInt64 == 0
                is_loading = false
            }
        }
    }
}

func mg_apply() {
    do {
        let cache_extra = mg_dict_now["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
        if !product_type.isEmpty {
            cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] = product_type
        }
        let artwork = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()
        artwork["ArtworkDeviceSubType"] = selected_st_value
        if enable_device_name {
            artwork["ArtworkDeviceProductDescription"] = mg_device_name
        }

        let data = try PropertyListSerialization.data(fromPropertyList: mg_dict_now, format: .xml, options: 0)
        try mg_write(data)
        mg_dict_now = NSMutableDictionary()
        print("[mg] successfully wrote MobileGestalt!")
    } catch {
        print("[mg] failed to apply: \(error)")
    }
}

func mg_revert() {
    do {
        let backup_url = URL(fileURLWithPath: TweakPaths.backups).appendingPathComponent("SavedGestalt.plist")
        let backup_data = try Data(contentsOf: backup_url)
        try mg_write(backup_data)
        print("[mg] successfully reverted!")
    } catch {
        print("[mg] failed to revert: \(error)")
    }
}

private func mg_write(_ data: Data, to path: String) throws {
    let og = try Data(contentsOf: URL(fileURLWithPath: path))

    let fd = path.withCString { Darwin.open($0, O_RDWR | O_CLOEXEC | O_NOFOLLOW) }
    guard fd >= 0 else { throw NSError(domain: "mg", code: 1, userInfo: [NSLocalizedDescriptionKey: "open failed: \(errno)"]) }

    defer { Darwin.close(fd) }

    guard ftruncate(fd, 0) == 0 else { throw NSError(domain: "mg", code: 2, userInfo: [NSLocalizedDescriptionKey: "truncate failed"]) }

    var offset = 0
    try data.withUnsafeBytes { raw in
        guard let base = raw.baseAddress else { return }
        while offset < data.count {
            let written = write(fd, base.advanced(by: offset), data.count - offset)
            if written > 0 { offset += written }
            else if errno == EINTR { continue }
            else { throw NSError(domain: "mg", code: 3, userInfo: [NSLocalizedDescriptionKey: "write failed: \(errno)"]) }
        }
    }

    guard fsync(fd) == 0 else { throw NSError(domain: "mg", code: 4, userInfo: [NSLocalizedDescriptionKey: "sync failed"]) }

    guard lseek(fd, 0, SEEK_SET) >= 0 else { throw NSError(domain: "mg", code: 5, userInfo: [NSLocalizedDescriptionKey: "seek failed"]) }

    var verify = Data()
    var buf = [UInt8](repeating: 0, count: 65536)
    while true {
        let n = buf.withUnsafeMutableBytes { read(fd, $0.baseAddress, $0.count) }
        if n > 0 { verify.append(buf, count: n) }
        else { break }
    }

    guard verify == data else {
        _ = ftruncate(fd, 0)
        _ = lseek(fd, 0, SEEK_SET)
        _ = try? og.withUnsafeBytes { raw in
            var off = 0
            while off < og.count {
                let w = write(fd, raw.baseAddress!.advanced(by: off), og.count - off)
                if w > 0 { off += w } else { break }
            }
        }
        _ = fsync(fd)
        throw NSError(domain: "mg", code: 6, userInfo: [NSLocalizedDescriptionKey: "verification failed"])
    }
}

func mg_write(_ data: Data) throws {
    let path = TweakPaths.gestalt
    if UserDefaults.standard.bool(forKey: "atomic_write") {
        try mg_write(data, to: path)
    } else {
        let target = URL(fileURLWithPath: path)
        let tmp = target.deletingLastPathComponent().appendingPathComponent(".tmp.\(UUID().uuidString)")
        try data.write(to: tmp, options: .withoutOverwriting)
        defer { try? FileManager.default.removeItem(at: tmp) }
        if FileManager.default.fileExists(atPath: target.path) {
            _ = try FileManager.default.replaceItemAt(target, withItemAt: tmp)
        } else {
            try FileManager.default.moveItem(at: tmp, to: target)
        }
    }
}

func mg_tweak_binding(_ tweak: mg_tweak) -> Binding<Bool> {
    Binding(
        get: { tweak.is_on(in: mg_dict_now) },
        set: { enabled in
            if enabled { tweak.apply_on(to: mg_dict_now) }
            else { tweak.apply_off(to: mg_dict_now) }
        }
    )
}
