import Foundation
import AppIntents
import SwiftData

public struct TripAppEntity: AppEntity, Identifiable, Sendable {
    public static let defaultQuery = TripEntityQuery()

    public static let typeDisplayRepresentation: TypeDisplayRepresentation = "Viaje"

    public var id: UUID
    public var title: String
    public var countryCode: String
    public var city: String?

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(city ?? countryCode)"
        )
    }

    public init(id: UUID, title: String, countryCode: String, city: String? = nil) {
        self.id = id
        self.title = title
        self.countryCode = countryCode
        self.city = city
    }
}

public struct TripEntityQuery: EntityQuery, Sendable {
    public init() {}

    public func entities(for identifiers: [UUID]) async throws -> [TripAppEntity] {
        // Simple query representation
        return []
    }

    public func suggestedEntities() async throws -> [TripAppEntity] {
        return [
            TripAppEntity(id: UUID(), title: "Kioto & Tokio", countryCode: "JP", city: "Kioto"),
            TripAppEntity(id: UUID(), title: "Roma & Florencia", countryCode: "IT", city: "Roma")
        ]
    }
}
