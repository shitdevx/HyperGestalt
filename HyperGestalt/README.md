HyperGestalt - iOS MobileGestalt & Capability Editor

## Overview

This project contains the source code for HyperGestalt, a sophisticated iOS application that enables users to modify MobileGestalt properties and system capabilities. The app allows devices (particularly iPad) to spoof device models and unlock features typically restricted to newer or different device types.

## Project Structure

### Core Components
- **Sources/** - Swift source code implementing the app's functionality
  - `PrivilegeEscalation/` - Kernel exploit integration and sandbox escape
  - `MobileGestalt/` - MobileGestalt property management
  - `Capabilities/` - Placard-style capability injection
  - `UI/` - User interface components
  - `FileManagement/` - Plist file operations and backup/restore
  - `Logging/` - Comprehensive logging system

- **External/** - External exploit dependencies
  - `darksword/` - darksword-kexploit kernel exploit (primary for iOS 15-26)
  - `bad_query/` - bad_query sandbox escape (fallback for iOS 26+)
  - `clipwire/` - clipwire kernel exploit (for iPhone 11 A13 on iOS 26.1)

- **Tests/** - Test suite for validation

## Key Features

### MobileGestalt Property Management
- Device model spoofing (100+ device models)
- Hardware capability flags (HasBattery, HasCamera, etc.)
- Feature flags (SupportsAlwaysOnDisplay, SupportsDynamicIsland, etc.)
- SoC/Processor identity spoofing

### Placard-Style Capability Injection
- Dynamic Island customization
- Always-On Display
- ProMotion (120Hz/144Hz)
- Cinematic Mode Video
- Portrait Mode & Depth Processing
- ProRAW & ProRes Video
- Spatial Audio/Dolby Vision
- Apple Intelligence spoofing
- Siri AI spoofing (3-tier system)

### File System Management
- Read/write binary and XML plist files
- Atomic writes with backup creation
- Versioned, timestamped backups
- File permission preservation

### Privilege Escalation & Sandbox Escape
- Version-specific exploit chains (darksword, bad_query, clipwire)
- Comprehensive failure logging
- Graceful degradation to read-only mode

## Build Instructions

1. Clone the repository
2. Add external exploit submodules:
   ```bash
   cd HyperGestalt
   git submodule add https://github.com/opa334/darksword-kexploit external/darksword
   git submodule add https://github.com/forcequitOS/bad_query external/bad_query
   ```
3. Open Project.xcodeproj in Xcode
4. Build for arm64 target

## Usage

1. Launch HyperGestalt on a jailbroken device
2. Follow the on-screen setup wizard to detect jailbreak and obtain privileges
3. Use the Dashboard to:
   - Spoof device model
   - Enable/disable features
   - Manage backups
   - Monitor system state

## Testing

Run the test suite to validate functionality:
```bash
xcodebuild test -project HyperGestalt.xcodeproj -scheme HyperGestalt -configuration Debug
```

## License

This project is for research and educational purposes only. Use with appropriate permissions and on devices you own.