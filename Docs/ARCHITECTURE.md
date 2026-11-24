# Architecture Specifications - Bitácora de Viajes iOS

## Overview
**Bitácora de Viajes** is a native iOS application built with **Swift 6** and **SwiftUI**, targeted for iOS 17.0+. It is designed with a Local-First approach prioritizing user privacy, speed, and offline resilience.

## Architectural Layers (MVVM Pattern)

### 1. Models (`BitacoraViajes/Models/`)
- Persistent domain entities managed via **SwiftData** (`Expedition`, `TripJournalEntry`, `CoinCollectible`, `TripExpense`, `CountryCatalog`).
- Conformances to `Sendable`, `Identifiable`, and `Codable` where appropriate to ensure strict Swift 6 concurrency safety across actor boundaries.

### 2. ViewModels (`BitacoraViajes/ViewModels/`)
- Observable state managers utilizing Apple's `@Observable` macro and `@MainActor` isolation.
- Handles user intent, filtering logic, and asynchronous coordination without retaining view hierarchies.

### 3. Views (`BitacoraViajes/Views/`)
- Modular SwiftUI interfaces.
- **Expeditions & Journal**: Dual-author travel chronicle with photo attachments.
- **Numismatic Cabinet**: 3D interactive coin inspection accelerated with GPU shaders and Metal compositor grouping (`.compositingGroup()`).
- **Expenses & Currency**: Shared expenses splitting with Swift Charts visual breakdown.
- **PDF Export**: Vector-based publication generator for travel memories.

### 4. Services (`BitacoraViajes/Services/`)
- **KeychainService**: Hardware-backed credential management using Apple Security framework (`kSecClassGenericPassword`).
- **BiometricAuthService**: LocalAuthentication wrapper with `OSLog` security audit logging.
- **ImageOptimizerService**: High-efficiency downsampling pipeline via `ImageIO` with memory exhaustion guards (30 MB raw limit).
- **WeatherService**: In-memory cached meteorological client querying Open-Meteo API over HTTPS.
- **APISyncService**: Secure HTTPS synchronization service with client rate-limiting.

## Data Flow & Persistence
```
[User Interface (SwiftUI Views)]
       │               ▲
       ▼               │ State Binding
[ViewModels (@Observable / @MainActor)]
       │               ▲
       ▼               │ Model Context
[SwiftData ModelContainer (SQLite in iOS Sandbox)]
```

## Security Posture
- **Strict Sandboxing**: No database access outside the application's unique sandbox container.
- **App Transport Security**: `NSAllowsArbitraryLoads = false` enforced in `Info.plist`.
- **Zero Third-Party Trackers**: No external analytics SDKs, advertising frameworks, or telemetry trackers.
