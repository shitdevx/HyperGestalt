import Foundation
import UIKit
import MachO

struct mg_tweak {
    let title: String
    let minv: Double?
    let info_msg: String?

    let r: (NSMutableDictionary) -> Bool
    let w_on: (NSMutableDictionary) -> Void
    let w_off: (NSMutableDictionary) -> Void

    init<T: Equatable>(title: String, minv: Double? = nil, key: String, value: T, info_msg: String? = nil) {
        self.init(
            title: title, minv: minv, info_msg: info_msg,
            r: { dict in
                guard let extra = dict["CacheExtra"] as? NSDictionary else { return false }
                return extra[key] as? T == value
            },
            w_on: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                extra[key] = value
            },
            w_off: { dict in
                guard let extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
                extra.removeObject(forKey: key)
            }
        )
    }

    init<T: Equatable>(title: String, minv: Double? = nil, keys: [String], value: T, info_msg: String? = nil) {
        self.init(
            title: title, minv: minv, info_msg: info_msg,
            r: { dict in
                guard let extra = dict["CacheExtra"] as? NSDictionary, let first = keys.first else { return false }
                return extra[first] as? T == value
            },
            w_on: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                for key in keys { extra[key] = value }
            },
            w_off: { dict in
                guard let extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
                for key in keys { extra.removeObject(forKey: key) }
            }
        )
    }

    init(title: String, minv: Double? = nil, info_msg: String? = nil,
         r: @escaping (NSMutableDictionary) -> Bool,
         w_on: @escaping (NSMutableDictionary) -> Void,
         w_off: @escaping (NSMutableDictionary) -> Void) {
        self.title = title
        self.minv = minv
        self.info_msg = info_msg
        self.r = r
        self.w_on = w_on
        self.w_off = w_off
    }

    private static func cache_extra(_ dict: NSMutableDictionary) -> NSMutableDictionary? {
        if let extra = dict["CacheExtra"] as? NSMutableDictionary { return extra }
        guard let extra = dict["CacheExtra"] as? NSDictionary else { return nil }
        let mutable = NSMutableDictionary(dictionary: extra)
        dict["CacheExtra"] = mutable
        return mutable
    }

    func is_on(in dict: NSMutableDictionary) -> Bool { r(dict) }
    func apply_on(to dict: NSMutableDictionary) { w_on(dict) }
    func apply_off(to dict: NSMutableDictionary) { w_off(dict) }
    func supported() -> Bool {
        guard let minv = minv else { return true }
        return doubleSystemVersion() >= minv
    }
}

let all_tweaks: [mg_tweak] = [
    mg_tweak(title: "Enable Dynamic Island", minv: 19.0, key: "YlEtTtHlNesRBMal1CqRaA", value: 1,
             info_msg: "Enable Dynamic Island on unsupported devices."),
    mg_tweak(title: "Always-On Display", minv: 18.0, keys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"], value: 1,
             info_msg: "Can increase screen burn-in risk."),
    mg_tweak(title: "AOD Vibrancy", minv: 18.0, key: "ykpu7qyhqFweVMKtxNylWA", value: 1,
             info_msg: "Turn on if AOD renders incorrectly."),
    mg_tweak(title: "Disable Wallpaper Parallax", key: "UIParallaxCapability", value: 0,
             info_msg: "Prevents wallpaper movement on tilt."),
    mg_tweak(title: "Boot & Shutdown Chime", key: "QHxt+hGLaBPbQJbXiUJX3w", value: 1,
             info_msg: "Adds chime on power on/off."),
    mg_tweak(title: "Charge Limit Menu", minv: 17.0, key: "37NVydb//GP/GrhuTN+exg", value: 1,
             info_msg: "Reveals charge limit settings."),
    mg_tweak(title: "Tap to Wake", key: "yZf3GTRMGTuwSV/lD7Cagw", value: 1,
             info_msg: "Enable tap-to-wake on older devices."),
    mg_tweak(title: "iPhone 16 Camera Control", minv: 18.0, keys: ["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"], value: 1,
             info_msg: "Exposes Camera Control settings."),
    mg_tweak(title: "Apple Pencil Settings", key: "yhHcB0iH0d1XzPO/CFd3ow", value: 1,
             info_msg: "Reveals Apple Pencil settings page."),
    mg_tweak(title: "Action Button Settings", minv: 17.0, key: "cT44WE1EohiwRzhsZ8xEsw", value: 1,
             info_msg: "Reveals Action Button settings."),
    mg_tweak(title: "Collision SOS", key: "HCzWusHQwZDea6nNhaKndw", value: 1,
             info_msg: "Reveals collision detection options."),
    mg_tweak(title: "Pulse Width Modulation", minv: 19.0, key: "6IejgN+1Fmu5/QrZFOIeNw", value: 1),
    mg_tweak(title: "Security Research Device", minv: 26.0, key: "XYlJKKkj2hztRP1NWWnhlw", value: 1,
             info_msg: "Flags device as Apple Security Research Device."),
    mg_tweak(title: "Allow iPad Apps", key: "9MZ5AdH43csAUajl/dU+IQ", value: [1, 2],
             info_msg: "Allows iPad apps on iPhone."),
    mg_tweak(title: "Stage Manager Support", key: "qeaj75wk3HF4DwQ8qbIi7g", value: 1,
             info_msg: "Flags device for Stage Manager."),
    mg_tweak(title: "Apple Internal Install", key: "EqrsVvjcYDdxHBiQmGhAWw", value: 1,
             info_msg: "Enables internal features like Metal HUD."),
    mg_tweak(title: "Internal Storage View", key: "LBJfwOEzExRxzlAnSuI7eg", value: 1,
             info_msg: "Shows internal files in Storage settings."),
    mg_tweak(title: "Apple Intelligence", minv: 18.1, key: "A62OafQ85EJAiiqKn4agtg", value: 1,
             info_msg: "Enable Apple Intelligence on unsupported devices."),
]

func tweak(_ title: String) -> mg_tweak? {
    all_tweaks.first { $0.title == title }
}

func machine_name() -> String {
    var sys_info = utsname()
    uname(&sys_info)
    let mirror = Mirror(reflecting: sys_info.machine)
    return mirror.children.reduce("") { id, el in
        guard let v = el.value as? Int8, v != 0 else { return id }
        return id + String(UnicodeScalar(UInt8(v)))
    }
}

func doubleSystemVersion() -> Double {
    let v = ProcessInfo.processInfo.operatingSystemVersion
    return Double(v.majorVersion) + Double(v.minorVersion) / 10.0 + Double(v.patchVersion) / 100.0
}
