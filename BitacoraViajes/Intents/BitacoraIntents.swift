import Foundation
import AppIntents
import SwiftUI

public struct AddQuickLogIntent: AppIntent, Sendable {
    public static let title: LocalizedStringResource = "Añadir Crónica Rápida"
    public static let description = IntentDescription("Registra una anécdota o recuerdo rápido en tu bitácora de viaje")

    public static let openAppWhenRun: Bool = true

    @Parameter(title: "Título de la Crónica")
    public var title: String

    @Parameter(title: "Notas o Anécdota")
    public var note: String

    public init() {
        self.title = ""
        self.note = ""
    }

    public init(title: String, note: String) {
        self.title = title
        self.note = note
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        // App will open and bring the user to record/save the log
        return .result(dialog: "¡Crónica preparada para guardar en tu Bitácora de Viajes!")
    }
}

public struct OpenPassportIntent: AppIntent, Sendable {
    public static let title: LocalizedStringResource = "Abrir Pasaporte Viajero"
    public static let description = IntentDescription("Muestra el mapa del mundo y sellos de países visitados")

    public static let openAppWhenRun: Bool = true

    public init() {}

    public func perform() async throws -> some IntentResult {
        return .result()
    }
}

public struct BitacoraShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddQuickLogIntent(),
            phrases: [
                "Añadir nota en \(.applicationName)",
                "Nueva crónica en \(.applicationName)",
                "Escribir recuerdo en \(.applicationName)"
            ],
            shortTitle: "Nueva Crónica",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenPassportIntent(),
            phrases: [
                "Ver mi pasaporte en \(.applicationName)",
                "Abrir mapa de viajes en \(.applicationName)"
            ],
            shortTitle: "Pasaporte Viajero",
            systemImageName: "globe.europe.africa.fill"
        )
    }
}
