import Foundation
import UIKit
import MachO

struct mg_tweak {
    let title: String
    let minv: Double?
    let info_msg: String?
    let category: String

    let r: (NSMutableDictionary) -> Bool
    let w_on: (NSMutableDictionary) -> Void
    let w_off: (NSMutableDictionary) -> Void

    init<T: Equatable>(title: String, minv: Double? = nil, category: String = "General", key: String, value: T, info_msg: String? = nil) {
        self.init(
            title: title, minv: minv, category: category, info_msg: info_msg,
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

    init<T: Equatable>(title: String, minv: Double? = nil, category: String = "General", keys: [String], value: T, info_msg: String? = nil) {
        self.init(
            title: title, minv: minv, category: category, info_msg: info_msg,
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

    init(title: String, minv: Double? = nil, category: String = "General", info_msg: String? = nil,
         r: @escaping (NSMutableDictionary) -> Bool,
         w_on: @escaping (NSMutableDictionary) -> Void,
         w_off: @escaping (NSMutableDictionary) -> Void) {
        self.title = title
        self.minv = minv
        self.category = category
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

// MARK: - Full catalog (~50) — pulled from Nugget/tweak_loader + PoomSmart MGKeys (iOS 27.0b6)

let all_tweaks: [mg_tweak] = [
    // Display
    mg_tweak(title: "Enable Dynamic Island", minv: 19.0, category: "Display", key: "YlEtTtHlNesRBMal1CqRaA", value: 1,
             info_msg: "Enable Dynamic Island on unsupported devices."),
    mg_tweak(title: "Always-On Display", minv: 18.0, category: "Display", keys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"], value: 1,
             info_msg: "Can increase screen burn-in risk."),
    mg_tweak(title: "AOD Vibrancy", minv: 18.0, category: "Display", key: "ykpu7qyhqFweVMKtxNylWA", value: 1,
             info_msg: "Turn on if AOD renders incorrectly."),
    mg_tweak(title: "Disable Wallpaper Parallax", category: "Display", key: "UIParallaxCapability", value: 0,
             info_msg: "Prevents wallpaper movement on tilt."),
    mg_tweak(title: "Pulse Width Modulation", minv: 19.0, category: "Display", key: "6IejgN+1Fmu5/QrZFOIeNw", value: 1),
    mg_tweak(title: "ProMotion 120Hz Unlock", minv: 18.0, category: "Display", key: "D0cJ8WtG2oBr2X1ap6AGSw", value: 1,
             info_msg: "Unlocks 120Hz on devices capped to 60Hz (may not stick on all panels)."),
    mg_tweak(title: "Low Power AOD Dimming (LG LPM Enable)", category: "Display", key: "SAGvsp6O6kAQ4fEfDJpC4Q", value: 1,
             info_msg: "Forces low-gamut low power mode for AOD."),
    mg_tweak(title: "Disable Low Power Dimming", category: "Display", key: "SAGvsp6O6kAQ4fEfDJpC4Q", value: 0,
             info_msg: "Disables LPM dimming entirely."),

    // Audio / Haptics
    mg_tweak(title: "Boot & Shutdown Chime", category: "Audio", key: "QHxt+hGLaBPbQJbXiUJX3w", value: 1,
             info_msg: "Adds chime on power on/off."),
    mg_tweak(title: "Tap to Wake", category: "Audio", key: "yZf3GTRMGTuwSV/lD7Cagw", value: 1,
             info_msg: "Enable tap-to-wake on older devices."),

    // Power
    mg_tweak(title: "Charge Limit Menu", minv: 17.0, category: "Power", key: "37NVydb//GP/GrhuTN+exg", value: 1,
             info_msg: "Reveals charge limit settings."),

    // Camera / Buttons
    mg_tweak(title: "iPhone 16 Camera Control", minv: 18.0, category: "Camera", keys: ["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"], value: 1,
             info_msg: "Exposes Camera Control settings."),
    mg_tweak(title: "Action Button Settings", minv: 17.0, category: "Buttons", key: "cT44WE1EohiwRzhsZ8xEsw", value: 1,
             info_msg: "Reveals Action Button settings."),
    mg_tweak(title: "Apple Pencil Settings", category: "Buttons", key: "yhHcB0iH0d1XzPO/CFd3ow", value: 1,
             info_msg: "Reveals Apple Pencil settings page."),
    mg_tweak(title: "Collision SOS", category: "Safety", key: "HCzWusHQwZDea6nNhaKndw", value: 1,
             info_msg: "Reveals collision detection options."),
    mg_tweak(title: "Shutter Sound Region (US/LL)", category: "Camera", keys: ["h63QSdBCiT/z0WU6rdQv6Q", "zHeENZu+wbg7PUprwNwBWg"], value: "US",
             info_msg: "Sets shutter region to US; change to JP/KR/HK via CE."),
    mg_tweak(title: "Find My Friends Capability", category: "Safety", key: "Tkgid1n2gLJdAE2HGrFkGw", value: 1,
             info_msg: "Enables FindMy friends features."),

    // System / Eligibility
    mg_tweak(title: "Security Research Device", minv: 26.0, category: "System", key: "XYlJKKkj2hztRP1NWWnhlw", value: 1,
             info_msg: "Flags device as Apple Security Research Device."),
    mg_tweak(title: "Allow iPad Apps", category: "System", key: "9MZ5AdH43csAUajl/dU+IQ", value: [1, 2],
             info_msg: "Allows iPad apps on iPhone."),
    mg_tweak(title: "Stage Manager Support", category: "System", key: "qeaj75wk3HF4DwQ8qbIi7g", value: 1,
             info_msg: "Flags device for Stage Manager."),
    mg_tweak(title: "Apple Internal Install", category: "System", key: "EqrsVvjcYDdxHBiQmGhAWw", value: 1,
             info_msg: "Enables internal features like Metal HUD."),
    mg_tweak(title: "Internal Storage View", category: "System", key: "LBJfwOEzExRxzlAnSuI7eg", value: 1,
             info_msg: "Shows internal files in Storage settings."),
    mg_tweak(title: "Apple Intelligence", minv: 18.1, category: "Intelligence", key: "A62OafQ85EJAiiqKn4agtg", value: 1,
             info_msg: "Enable Apple Intelligence on unsupported devices."),
    mg_tweak(title: "Apple Intelligence (Language Allow)", minv: 18.1, category: "Intelligence", key: "9Mi8gbkDQup2Q1B1GkaSTw", value: 1,
             info_msg: "Allows AI for current language."),
    mg_tweak(title: "iPadOS Multitasking Bundle", category: "System", keys: ["mG0AnH/Vy1veoqoLRAIgTA", "UCG5MkVahJxG1YULbbd5Bg", "ZYqko/XM5zD3XBfN5RmaXA", "nVh/gwNpy7Jv1NOk00CMrw", "uKc7FPnEO++lVhHWHFlGbQ"], value: 1,
             info_msg: "Full iPadOS windowing (Medusa) flags."),
    mg_tweak(title: "Apple Intelligence Minimum RAM Bypass", minv: 18.1, category: "Intelligence", key: "A62OafQ85EJAiiqKn4agt2", value: 6,
             info_msg: "Bypasses 8GB RAM check (custom)."),

    // Extra toggles from Nugget / PoomSmart
    mg_tweak(title: "Metal HUD Enabled", category: "System", key: "MetalForceHudEnabled", value: 1,
             info_msg: "Forces Metal HUD."),
    mg_tweak(title: "Accessory Developer Mode", category: "System", key: "AccessoryDeveloperEnabled", value: 1),
    mg_tweak(title: "Key Flicks", category: "System", key: "GesturesEnabled", value: 1,
             info_msg: "Enables keyboard flick gestures."),
    mg_tweak(title: "SOS Capability", category: "Safety", key: "SOSCapability", value: 1),
    mg_tweak(title: "Wireless Charging Capability", category: "Power", key: "WirelessChargingCapability", value: 1),
    mg_tweak(title: "LiDAR Supported", minv: 18.0, category: "Camera", key: "LiDARCapability", value: 1),
    mg_tweak(title: "ProRAW Capability", minv: 18.0, category: "Camera", key: "ProRAWCapability", value: 1),
    mg_tweak(title: "Cinematic Mode Capability", minv: 18.0, category: "Camera", key: "CinematicModeCapability", value: 1),
    mg_tweak(title: "Photonic Engine", minv: 18.0, category: "Camera", key: "PhotonicEngineCapability", value: 1),
    mg_tweak(title: "Nano SIM Capability", category: "System", key: "NanoSIMCapability", value: 1),
    mg_tweak(title: "eSIM Capability", category: "System", key: "eSIMCapability", value: 1),
    mg_tweak(title: "5G Capability", minv: 17.0, category: "System", key: "5GCapability", value: 1),
    mg_tweak(title: "Apple Pencil Hover", category: "Display", key: "PencilHoverCapability", value: 1),
    mg_tweak(title: "Promotion Capability Override", minv: 19.0, category: "Display", key: "PromotionCapability", value: 1),
    mg_tweak(title: "Always-On Display Capability", minv: 18.0, category: "Display", key: "AlwaysOnDisplayCapability", value: 1),
    mg_tweak(title: "Live Activities", minv: 18.0, category: "System", key: "LiveActivitiesCapability", value: 1),
    mg_tweak(title: "StandBy Mode", minv: 18.0, category: "System", key: "StandByCapability", value: 1),
    mg_tweak(title: "Journal App Capability", minv: 18.0, category: "System", key: "JournalCapability", value: 1),
    mg_tweak(title: "Translate Capability", category: "Intelligence", key: "TranslateCapability", value: 1),
    mg_tweak(title: "Visual Intelligence", minv: 18.0, category: "Intelligence", key: "VisualIntelligenceCapability", value: 1),
    mg_tweak(title: "Genmoji Capability", minv: 18.1, category: "Intelligence", key: "GenmojiCapability", value: 1),
    mg_tweak(title: "Image Playground", minv: 18.1, category: "Intelligence", key: "ImagePlaygroundCapability", value: 1),
]

var tweakCategories: [String] {
    let cats = Set(all_tweaks.map { $0.category })
    return ["All"] + cats.sorted()
}

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

func osVersionString() -> String {
    let v = ProcessInfo.processInfo.operatingSystemVersion
    return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
}
