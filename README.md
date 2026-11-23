# BitacoraViajes (iOS Native)

Native iOS application built with SwiftUI, SwiftData, and Swift 6 for couples documenting shared journeys, numismatic collections, and travel memorabilia.

## Highlights

- **3D Coin & Banknote Viewer**: Interactive flip cards with tactile 180° rotation, ProMotion support, and haptics.
- **Vision AI Coin Scanner**: Automatic circular contour isolation and metal relief enhancement with CoreImage and Vision.
- **Dual-Voice Chronicles**: Side-by-side daily journal logging from two simultaneous perspectives.
- **Shared Expense Splitter**: Donut charts with Swift Charts, balance breakdown, and automatic 50/50 settle-up calculations.
- **Live Activities & Dynamic Island**: Real-time expedition tracker showing days, country flags, and latest entries.
- **Widgets (WidgetKit)**: Home Screen countdown and active journey widgets.
- **Spotlight & Siri (AppIntents)**: Deep system indexing and voice shortcuts ("Añadir crónica rápida").
- **CloudKit Sync**: Transparent multi-device and partner synchronization via private iCloud container.
- **Memorabilia Showcase**: Tickets, transport passes, postcards, and travel souvenirs catalog.
- **Passport & MapKit**: Travel metrics and interactive map annotations for visited cities and countries.
- **Editorial PDF Export**: Clean, printable A4 travel book generated natively with PDFKit.
- **Weather Integration**: Historical weather retrieval using the Open-Meteo API.
- **Privacy First & Biometrics**: Optional Face ID protection, SwiftData storage, and zero telemetry.
- **Bilingual Localization**: Native support for English and Spanish with String Catalogs (`.xcstrings`).

## Technical Architecture

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI (Declarative, MVVM with `@Observable`)
- **Persistence**: SwiftData (`@Model`) with CloudKit syncing
- **System Frameworks**: ActivityKit, WidgetKit, AppIntents, Vision, Charts, MapKit, TipKit, LocalAuthentication, PDFKit, PhotosUI
- **Project Tool**: XcodeGen

## Building the Project

```bash
# Generate the Xcode project
xcodegen generate

# Open with Xcode
open BitacoraViajes.xcodeproj
```

You can also build directly with `xcodebuild`:

```bash
xcodebuild -project BitacoraViajes.xcodeproj \
           -scheme BitacoraViajes \
           -destination "platform=iOS Simulator,name=iPhone 18 Pro" \
           -configuration Debug build
```

## Privacy & Compliance

- Privacy manifest included (`PrivacyInfo.xcprivacy`) with required-reason API declaration `CA92.1`.
- Fully offline-first design without tracking or third-party SDK dependencies.

## License

MIT License.
