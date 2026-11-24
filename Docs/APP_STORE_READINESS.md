# App Store Readiness & Review Compliance

## Guidelines Audit Summary

### 1. Privacy Manifest (`PrivacyInfo.xcprivacy`)
- Location: `BitacoraViajes/Resources/PrivacyInfo.xcprivacy`
- **NSPrivacyTracking**: Set to `false`. The application does not track users or link personal data across external apps or websites.
- **NSPrivacyCollectedDataTypes**: Empty array. No user identifiable data is collected, harvested, or transmitted to third-party data brokers.
- **NSPrivacyAccessedAPITypes**:
  - `NSPrivacyAccessedAPICategoryUserDefaults`: Declared with reason code `CA92.1` for storing user interface preferences and onboarding state.

### 2. System Permissions & Info.plist
- **Face ID Usage**: `NSFaceIDUsageDescription` declared in `Info.plist` with clear, user-facing rationale: *"Protege el acceso a tus recuerdos y notas de viaje privadas."*
- **Photo Library**: Uses Apple's modern out-of-process `PhotosPicker` (`PhotosUI`). Does not require invasive `NSPhotoLibraryUsageDescription` because the user selects items directly via the system picker interface.

### 3. Network & Transport Security
- **ATS Enforcement**: `NSAllowsArbitraryLoads` is explicitly set to `false`. All external network queries (such as weather forecasts from Open-Meteo) strictly require `https://` transport.
- **No Private APIs**: Clean Swift 6 codebase adhering strictly to public Apple SDK interfaces.
