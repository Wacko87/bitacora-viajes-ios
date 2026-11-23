import Foundation
import SwiftData

@Model
public final class TripPhoto {
    @Attribute(.unique) public var id: UUID
    @Attribute(.externalStorage) public var imageData: Data
    public var caption: String?
    public var location: String?
    public var takenAt: Date?
    public var createdAt: Date

    public var trip: Trip?

    public init(
        id: UUID = UUID(),
        imageData: Data,
        caption: String? = nil,
        location: String? = nil,
        takenAt: Date? = nil,
        createdAt: Date = Date(),
        trip: Trip? = nil
    ) {
        self.id = id
        self.imageData = imageData
        self.caption = caption
        self.location = location
        self.takenAt = takenAt
        self.createdAt = createdAt
        self.trip = trip
    }
}
