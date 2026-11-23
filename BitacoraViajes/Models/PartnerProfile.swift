import Foundation

public struct PartnerProfile: Identifiable, Codable, Sendable {
    public let id: String
    public var name: String
    public var role: String
    public var avatarColorHex: String

    public init(id: String, name: String, role: String, avatarColorHex: String) {
        self.id = id
        self.name = name
        self.role = role
        self.avatarColorHex = avatarColorHex
    }

    public static let defaultPartner1 = PartnerProfile(
        id: "partner_1",
        name: "Oscar",
        role: "partner_1",
        avatarColorHex: "#F59E0B"
    )

    public static let defaultPartner2 = PartnerProfile(
        id: "partner_2",
        name: "Pareja",
        role: "partner_2",
        avatarColorHex: "#EC4899"
    )
}
