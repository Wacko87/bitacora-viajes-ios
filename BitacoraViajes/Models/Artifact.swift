import Foundation
import SwiftData

public enum ArtifactCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    case coin = "coin"
    case banknote = "banknote"
    case ticket = "ticket"
    case postcard = "postcard"
    case souvenir = "souvenir"

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .coin: return "Moneda"
        case .banknote: return "Billete"
        case .ticket: return "Ticket / Entrada"
        case .postcard: return "Postal"
        case .souvenir: return "Souvenir"
        }
    }

    public var systemIcon: String {
        switch self {
        case .coin: return "circle.circle.fill"
        case .banknote: return "banknote.fill"
        case .ticket: return "ticket.fill"
        case .postcard: return "envelope.fill"
        case .souvenir: return "gift.fill"
        }
    }

    public var isNumismatic: Bool {
        self == .coin || self == .banknote
    }
}

@Model
public final class Artifact {
    @Attribute(.unique) public var id: UUID
    public var categoryRaw: String
    public var title: String
    public var currencyCode: String?
    public var denomination: String?
    public var year: Int?
    @Attribute(.externalStorage) public var imageFrontData: Data?
    @Attribute(.externalStorage) public var imageBackData: Data?
    public var story: String?
    public var countryCode: String?
    public var collectorProfileId: String?
    public var createdAt: Date
    public var updatedAt: Date

    public var trip: Trip?

    public var category: ArtifactCategory {
        get { ArtifactCategory(rawValue: categoryRaw) ?? .coin }
        set { categoryRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        category: ArtifactCategory = .coin,
        title: String,
        currencyCode: String? = nil,
        denomination: String? = nil,
        year: Int? = nil,
        imageFrontData: Data? = nil,
        imageBackData: Data? = nil,
        story: String? = nil,
        countryCode: String? = nil,
        collectorProfileId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        trip: Trip? = nil
    ) {
        self.id = id
        self.categoryRaw = category.rawValue
        self.title = title
        self.currencyCode = currencyCode
        self.denomination = denomination
        self.year = year
        self.imageFrontData = imageFrontData
        self.imageBackData = imageBackData
        self.story = story
        self.countryCode = countryCode
        self.collectorProfileId = collectorProfileId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.trip = trip
    }
}
