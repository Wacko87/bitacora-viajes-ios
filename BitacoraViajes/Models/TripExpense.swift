import Foundation
import SwiftData

public enum ExpenseCategory: String, CaseIterable, Codable, Sendable {
    case food = "food"
    case transport = "transport"
    case lodging = "lodging"
    case activities = "activities"
    case shopping = "shopping"
    case tickets = "tickets"
    case other = "other"

    public var localizedTitle: String {
        switch self {
        case .food: return "Comida y Restaurantes"
        case .transport: return "Transporte"
        case .lodging: return "Alojamiento"
        case .activities: return "Actividades y Ocio"
        case .shopping: return "Compras y Souvenirs"
        case .tickets: return "Vuelos y Entradas"
        case .other: return "Otros Gastos"
        }
    }

    public var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "tram.fill"
        case .lodging: return "bed.double.fill"
        case .activities: return "ticket.fill"
        case .shopping: return "bag.fill"
        case .tickets: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

public enum ExpenseSplit: String, CaseIterable, Codable, Sendable {
    case equal = "equal"
    case allP1 = "allP1"
    case allP2 = "allP2"

    public var localizedTitle: String {
        switch self {
        case .equal: return "50% / 50% (A partes iguales)"
        case .allP1: return "100% Viajero 1"
        case .allP2: return "100% Viajero 2"
        }
    }
}

@Model
public final class TripExpense {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var amount: Double
    public var currencyCode: String
    public var exchangeRateToEUR: Double
    public var categoryRaw: String
    public var paidByPartnerIndex: Int
    public var splitRaw: String
    public var date: Date
    public var notes: String?
    public var createdAt: Date

    public var trip: Trip?

    public var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    public var split: ExpenseSplit {
        get { ExpenseSplit(rawValue: splitRaw) ?? .equal }
        set { splitRaw = newValue.rawValue }
    }

    public var amountInEUR: Double {
        if currencyCode.uppercased() == "EUR" || exchangeRateToEUR <= 0 {
            return amount
        }
        return amount * exchangeRateToEUR
    }

    public var partner1ShareInEUR: Double {
        switch split {
        case .equal:
            return amountInEUR / 2.0
        case .allP1:
            return amountInEUR
        case .allP2:
            return 0.0
        }
    }

    public var partner2ShareInEUR: Double {
        switch split {
        case .equal:
            return amountInEUR / 2.0
        case .allP1:
            return 0.0
        case .allP2:
            return amountInEUR
        }
    }

    public init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        currencyCode: String = "EUR",
        exchangeRateToEUR: Double = 1.0,
        category: ExpenseCategory = .food,
        paidByPartnerIndex: Int = 0,
        split: ExpenseSplit = .equal,
        date: Date = Date(),
        notes: String? = nil,
        createdAt: Date = Date(),
        trip: Trip? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currencyCode = currencyCode
        self.exchangeRateToEUR = exchangeRateToEUR
        self.categoryRaw = category.rawValue
        self.paidByPartnerIndex = paidByPartnerIndex
        self.splitRaw = split.rawValue
        self.date = date
        self.notes = notes
        self.createdAt = createdAt
        self.trip = trip
    }
}
