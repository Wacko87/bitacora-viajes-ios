import Foundation
import SwiftData

public enum TripStatus: String, CaseIterable, Codable, Sendable {
    case active = "active"
    case completed = "completed"
    case planned = "planned"

    public var localizedTitle: String {
        switch self {
        case .active: return "Activo"
        case .completed: return "Completado"
        case .planned: return "Planificado"
        }
    }
}

@Model
public final class Trip {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var countryCode: String
    public var city: String?
    public var startDate: Date
    public var endDate: Date
    @Attribute(.externalStorage) public var coverImageData: Data?
    public var statusRaw: String
    public var summary: String?
    public var totalCost: Double?
    public var costCurrency: String?
    public var inclusions: String?
    public var costNotes: String?
    public var tempMin: Double?
    public var tempMax: Double?
    public var createdAt: Date
    public var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TripLog.trip)
    public var logs: [TripLog] = []

    @Relationship(deleteRule: .cascade, inverse: \Artifact.trip)
    public var artifacts: [Artifact] = []

    @Relationship(deleteRule: .cascade, inverse: \TripPhoto.trip)
    public var photos: [TripPhoto] = []

    @Relationship(deleteRule: .cascade, inverse: \TripExpense.trip)
    public var expenses: [TripExpense] = []

    public var status: TripStatus {
        get { TripStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    public var durationInDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(1, (components.day ?? 0) + 1)
    }

    public init(
        id: UUID = UUID(),
        title: String,
        countryCode: String,
        city: String? = nil,
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(86400 * 3),
        coverImageData: Data? = nil,
        status: TripStatus = .active,
        summary: String? = nil,
        totalCost: Double? = nil,
        costCurrency: String? = "EUR",
        inclusions: String? = nil,
        costNotes: String? = nil,
        tempMin: Double? = nil,
        tempMax: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.countryCode = countryCode
        self.city = city
        self.startDate = startDate
        self.endDate = endDate
        self.coverImageData = coverImageData
        self.statusRaw = status.rawValue
        self.summary = summary
        self.totalCost = totalCost
        self.costCurrency = costCurrency
        self.inclusions = inclusions
        self.costNotes = costNotes
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
