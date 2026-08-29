# HyperGestalt

Modify `MobileGestalt` on **iOS 15 → iOS 27 beta 6** — on-device, no computer. Badges, Dynamic Island, AOD, Apple Intelligence and 40+ other features via `CacheExtra` spoofing.

Built from [mond](https://github.com/rooootdev/mond) + [`bad_query`](https://github.com/shitdevx/HyperGestalt/tree/main/external/bad_query) (`containermanagerd` sandbox escape), with `cmg` fallback. SwiftUI, iOS 15+ (`project.yml:11`).

> **Stock sideload works** on 15 → 27.0 beta 6 — no jailbreak / TrollStore needed. The app gains its own sandbox extension at runtime (`SandboxExploit.swift:7` → `bad_query` class 13 → `sandbox_extension_consume`), then `open(O_RDWR)`s `TweakPaths.gestalt:6`.

## Install

1. **Download IPA** — GitHub Actions → latest `HyperGestalt-ipa` (green check). Direct: `https://github.com/shitdevx/HyperGestalt/actions`
2. **Sideload** — `AltStore` / `SideStore` / `Sideloadly` with free Apple ID (stock) or `TrollStore` if you have it. No entitlements required at install — the exploit grants itself.
3. **Trust** — Settings → General → VPN & Device Management → trust cert.

## Usage

1. Open HyperGestalt → **Logs** shows `Not Run`.
2. Tap **Run Exploit** (`ContentView.swift:14`). Wait for `[ok] MG access granted (fd=…)`. If `bad_query` fails it auto-retries `cmg` (`(1<<32)|(1<<39)`). All steps log to **Logs** — long-press to copy.
3. **MobileGestalt** (`GestaltView.swift:3`) — pick category (`All`/`Display`/`Intelligence`/…), toggle, then **Apply Tweaks**. You’ll see `[verify] on-disk … YlEtTtHlNesRBMal1CqRaA=1 …` if `mg_write:151` succeeded.
4. **Respring** — tap **Respring** in app (`MGManager.swift:14` `posix_spawn` `sbreload`/`killall backboardd`) or run `ldrestart`. Required for `CacheExtra` to reload.
5. **CacheExtra Editor** (`CEView.swift:1`) — raw `CacheExtra` browser: search keys *and* values, type-aware edit (Int/Bool/String/Data base64), import/export presets (`Documents/HyperGestaltPresets`), share.
6. **Diff** — `Show Diff vs Backup` before/after `Apply`.
7. **Revert** — `Revert Tweaks` restores `SavedGestalt.plist` from `ApplicationSupport/backups` (`TweakPaths.backups:8`).

> If `Apply` says `apply failed: open failed: 1` → exploit didn’t stick, re-run. If `verify … =<missing>` → key didn’t persist, try non-atomic write in **Settings → Atomic Write**.

## Tweaks — 46 in `MGHelper.swift:83` (`PoomSmart/MGKeys` iOS 27.0b6 + `Nugget/tweak_loader.py`)

**Display (11):** Enable Dynamic Island (`YlEtTtHlNesRBMal1CqRaA`), Always-On Display (`2OOJf1VhaM7NxfRok3HbWQ`/`j8/Omm6s1lsmTDFsXjsBfA`), AOD Vibrancy, Disable Wallpaper Parallax, Pulse Width Modulation, ProMotion 120Hz Unlock, Low Power AOD Dimming / Disable (`SAGvsp6O6kAQ4fEfDJpC4Q`), Apple Pencil Hover, Promotion Override, Always-On Display Capability

**Camera/Buttons (7):** iPhone 16 Camera Control (`CwvKxM2cEogD3p+HYgaW0Q`), Action Button, Apple Pencil Settings, Shutter Region US/LL (`h63QSdBCiT…`), LiDAR, ProRAW, Cinematic Mode, Photonic Engine

**Audio/Safety/Power (7):** Boot & Shutdown Chime (`QHxt+hGLaBPbQJbXiUJX3w`), Tap to Wake, Charge Limit, Collision SOS, Find My Friends, SOS, Wireless Charging, Nano/eSIM, 5G

**System (11):** Allow iPad Apps, Stage Manager (`qeaj75wk3HF4DwQ8qbIi7g`), Apple Internal Install, Internal Storage, Security Research Device (`XYlJKKkj2hztRP1NWWnhlw`), iPadOS Multitasking Bundle (5 keys `mG0AnH…`), Metal HUD, Accessory Developer, Key Flicks, Live Activities, StandBy, Journal

**Intelligence (6):** Apple Intelligence (`A62OafQ85EJAiiqKn4agtg`), Language Allow, Minimum RAM Bypass, Translate, Visual Intelligence, Genmoji, Image Playground

Plus **Device Artwork** picker (`ArworkDeviceSubType` `oPeik/9e8lQWMszEjbPzng` 2436/2556/2796/2622/2868/2736) and **Eligibility** spoof `h9jDsbgj7xIVeIQ8S3/X3Q` (`iPhone16,1`/`17,1`/`iPad16,5`…).

## Compatibility

| Device | iOS | Works? |
|---|---|---|
| Anything iOS 15–26.1 | Stock sideload | ✅ `bad_query` |
| iPad 9th / iPhone 11 (A13) stock | 27.0 beta 1–6 | ✅ tested on iPad 9 `iPad12,1` 27b1 |
| iOS 26.2+ | Any | ❌ Apple seals gestalt (`signed-gestalt`) |
| Needs jailbreak? | — | No. TrollStore optional. `CODE_SIGNING_ALLOWED=NO`. |

`doubleSystemVersion()` / `osVersionString()` gates `minv` (e.g. Dynamic Island 19.0, SRD 26.0).

## Troubleshooting

- **App crashes on launch** → you’re on pre-`a1b02df`; update — exploit no longer auto-runs on `onAppear` (`HyperGestaltApp.swift:18`).
- **MG access denied** → `Logs` shows real `bad_query` code: `-3` rejected, `-4` kernel refused, `open errno 1` still sandboxed. Re-run; `cmg` fallback logs `cmg …`.
- **Tweak says success but no change after respring** → check `CacheExtra Editor` for key, then `verify` line. If `verify` shows `1` but no UI change, key rotated in your iOS build — open `CEView` and set via raw key.
- **Plist empty/invalid warning** (`GestaltView.swift:13`) → **Do not reboot** — `Apply` is blocked, `Revert` from backup.

## Build

```bash
brew install xcodegen ldid
xcodegen generate --spec project.yml
xcodebuild -project HyperGestalt.xcodeproj -scheme HyperGestalt -sdk iphoneos -derivedDataPath build/DD CODE_SIGNING_ALLOWED=NO
# IPA: build/DD/Build/Products/Release-iphoneos/HyperGestalt.app → zip to Payload/
```

CI: `.github/workflows/build.yml` (`macos-14`, Xcode 15.4, `xcodegen` objectVersion 56, `ldid -S`).

## Credits

- `forcequit` — `bad_query` sandbox escape (`external/bad_query`)
- `opa334` — `darksword` kexploit (artifact, not used at runtime yet)
- `roooot` — `mond` reference app
- `leminlimez` / `PoomSmart` — `Nugget` / `MGKeys` tweak DB

## License

Same as `mond` — see repo license.

## Safety

You’re writing to `/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist`. A bad write can bootloop. `mg_write:151` does `ftruncate`/`write`/`fsync` + read-back verify and restores `og` on mismatch. Backups live in `ApplicationSupport/backups/SavedGestalt.plist`. If `is_empty` after write, **restore before reboot**.
