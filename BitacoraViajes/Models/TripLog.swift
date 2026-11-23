import Foundation
import SwiftData

@Model
public final class TripLog {
    @Attribute(.unique) public var id: UUID
    public var dayNumber: Int?
    public var logDate: Date
    public var title: String?
    public var notesPartner1: String?
    public var notesPartner2: String?
    public var createdAt: Date

    public var trip: Trip?

    public init(
        id: UUID = UUID(),
        dayNumber: Int? = nil,
        logDate: Date = Date(),
        title: String? = nil,
        notesPartner1: String? = nil,
        notesPartner2: String? = nil,
        createdAt: Date = Date(),
        trip: Trip? = nil
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.logDate = logDate
        self.title = title
        self.notesPartner1 = notesPartner1
        self.notesPartner2 = notesPartner2
        self.createdAt = createdAt
        self.trip = trip
    }
}
