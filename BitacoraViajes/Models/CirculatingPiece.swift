import Foundation

public struct CirculatingPiece: Identifiable, Codable, Sendable {
    public let id: String
    public let countryCode: String
    public let category: ArtifactCategory
    public let denomination: String
    public let displayValue: String
    public let currencyCode: String
    public let currencySymbol: String
    public let name: String
    public let motif: String?
    public let material: String?
    public let badgeColorHex: String

    public init(
        id: String,
        countryCode: String,
        category: ArtifactCategory,
        denomination: String,
        displayValue: String,
        currencyCode: String,
        currencySymbol: String,
        name: String,
        motif: String? = nil,
        material: String? = nil,
        badgeColorHex: String = "#F59E0B"
    ) {
        self.id = id
        self.countryCode = countryCode
        self.category = category
        self.denomination = denomination
        self.displayValue = displayValue
        self.currencyCode = currencyCode
        self.currencySymbol = currencySymbol
        self.name = name
        self.motif = motif
        self.material = material
        self.badgeColorHex = badgeColorHex
    }

    public static func series(for countryCode: String) -> [CirculatingPiece] {
        let code = countryCode.uppercased()
        switch code {
        case "ES", "FR", "IT", "DE", "PT", "GR":
            return euroSeries(countryCode: code)
        case "JP":
            return japanSeries()
        case "GB":
            return ukSeries()
        case "US":
            return usSeries()
        case "EG":
            return egyptSeries()
        default:
            return genericSeries(countryCode: code)
        }
    }

    private static func euroSeries(countryCode: String) -> [CirculatingPiece] {
        [
            CirculatingPiece(id: "\(countryCode)-coin-1c", countryCode: countryCode, category: .coin, denomination: "0.01", displayValue: "1 Cent", currencyCode: "EUR", currencySymbol: "€", name: "1 Céntimo de Euro", motif: "Acero recubierto de cobre", material: "Cobre", badgeColorHex: "#B45309"),
            CirculatingPiece(id: "\(countryCode)-coin-5c", countryCode: countryCode, category: .coin, denomination: "0.05", displayValue: "5 Cent", currencyCode: "EUR", currencySymbol: "€", name: "5 Céntimos de Euro", motif: "Globo terráqueo", material: "Cobre", badgeColorHex: "#B45309"),
            CirculatingPiece(id: "\(countryCode)-coin-10c", countryCode: countryCode, category: .coin, denomination: "0.10", displayValue: "10 Cent", currencyCode: "EUR", currencySymbol: "€", name: "10 Céntimos de Euro", motif: "Oro nórdico", material: "Oro nórdico", badgeColorHex: "#F59E0B"),
            CirculatingPiece(id: "\(countryCode)-coin-20c", countryCode: countryCode, category: .coin, denomination: "0.20", displayValue: "20 Cent", currencyCode: "EUR", currencySymbol: "€", name: "20 Céntimos de Euro", motif: "Borde español acanalado", material: "Oro nórdico", badgeColorHex: "#F59E0B"),
            CirculatingPiece(id: "\(countryCode)-coin-50c", countryCode: countryCode, category: .coin, denomination: "0.50", displayValue: "50 Cent", currencyCode: "EUR", currencySymbol: "€", name: "50 Céntimos de Euro", motif: "Diseño nacional", material: "Oro nórdico", badgeColorHex: "#F59E0B"),
            CirculatingPiece(id: "\(countryCode)-coin-1e", countryCode: countryCode, category: .coin, denomination: "1", displayValue: "1 €", currencyCode: "EUR", currencySymbol: "€", name: "1 Euro Bimetálico", motif: "Centro cuproníquel / anillo latón", material: "Bimetálica", badgeColorHex: "#EAB308"),
            CirculatingPiece(id: "\(countryCode)-coin-2e", countryCode: countryCode, category: .coin, denomination: "2", displayValue: "2 €", currencyCode: "EUR", currencySymbol: "€", name: "2 Euros Bimetálico", motif: "Centro latón / anillo cuproníquel", material: "Bimetálica", badgeColorHex: "#EAB308"),
            CirculatingPiece(id: "\(countryCode)-note-5e", countryCode: countryCode, category: .banknote, denomination: "5", displayValue: "5 €", currencyCode: "EUR", currencySymbol: "€", name: "Billete de 5 Euros", motif: "Arquitectura clásica", material: "Fibra de algodón", badgeColorHex: "#64748B"),
            CirculatingPiece(id: "\(countryCode)-note-10e", countryCode: countryCode, category: .banknote, denomination: "10", displayValue: "10 €", currencyCode: "EUR", currencySymbol: "€", name: "Billete de 10 Euros", motif: "Arquitectura románica", material: "Fibra de algodón", badgeColorHex: "#EF4444"),
            CirculatingPiece(id: "\(countryCode)-note-20e", countryCode: countryCode, category: .banknote, denomination: "20", displayValue: "20 €", currencyCode: "EUR", currencySymbol: "€", name: "Billete de 20 Euros", motif: "Arquitectura gótica", material: "Fibra de algodón", badgeColorHex: "#3B82F6")
        ]
    }

    private static func japanSeries() -> [CirculatingPiece] {
        [
            CirculatingPiece(id: "JP-coin-1", countryCode: "JP", category: .coin, denomination: "1", displayValue: "1 ¥", currencyCode: "JPY", currencySymbol: "¥", name: "1 Yen", motif: "Brote de árbol joven", material: "Aluminio 100%", badgeColorHex: "#94A3B8"),
            CirculatingPiece(id: "JP-coin-5", countryCode: "JP", category: .coin, denomination: "5", displayValue: "5 ¥", currencyCode: "JPY", currencySymbol: "¥", name: "5 Yenes (Agujero)", motif: "Espiga de arroz y engranaje", material: "Latón", badgeColorHex: "#F59E0B"),
            CirculatingPiece(id: "JP-coin-10", countryCode: "JP", category: .coin, denomination: "10", displayValue: "10 ¥", currencyCode: "JPY", currencySymbol: "¥", name: "10 Yenes", motif: "Templo Byodoin de Kioto", material: "Bronce", badgeColorHex: "#B45309"),
            CirculatingPiece(id: "JP-coin-50", countryCode: "JP", category: .coin, denomination: "50", displayValue: "50 ¥", currencyCode: "JPY", currencySymbol: "¥", name: "50 Yenes (Agujero)", motif: "Flor de crisantemo", material: "Cuproníquel", badgeColorHex: "#64748B"),
            CirculatingPiece(id: "JP-coin-100", countryCode: "JP", category: .coin, denomination: "100", displayValue: "100 ¥", currencyCode: "JPY", currencySymbol: "¥", name: "100 Yenes", motif: "Flores de cerezo (Sakura)", material: "Cuproníquel", badgeColorHex: "#CBD5E1"),
            CirculatingPiece(id: "JP-coin-500", countryCode: "JP", category: .coin, denomination: "500", displayValue: "500 ¥", currencyCode: "JPY", currencySymbol: "¥", name: "500 Yenes Bicolor", motif: "Paulownia imperial", material: "Bimetálica", badgeColorHex: "#EAB308"),
            CirculatingPiece(id: "JP-note-1000", countryCode: "JP", category: .banknote, denomination: "1000", displayValue: "1.000 ¥", currencyCode: "JPY", currencySymbol: "¥", name: "Billete de 1.000 Yenes", motif: "Monte Fuji y Sakura", material: "Papel japonés", badgeColorHex: "#10B981")
        ]
    }

    private static func ukSeries() -> [CirculatingPiece] {
        [
            CirculatingPiece(id: "GB-coin-1p", countryCode: "GB", category: .coin, denomination: "0.01", displayValue: "1p", currencyCode: "GBP", currencySymbol: "£", name: "1 Penique", motif: "Lirón común", material: "Acero cobreado", badgeColorHex: "#B45309"),
            CirculatingPiece(id: "GB-coin-5p", countryCode: "GB", category: .coin, denomination: "0.05", displayValue: "5p", currencyCode: "GBP", currencySymbol: "£", name: "5 Peniques", motif: "Hojas de roble", material: "Acero niquelado", badgeColorHex: "#94A3B8"),
            CirculatingPiece(id: "GB-coin-10p", countryCode: "GB", category: .coin, denomination: "0.10", displayValue: "10p", currencyCode: "GBP", currencySymbol: "£", name: "10 Peniques", motif: "Urogallo", material: "Acero niquelado", badgeColorHex: "#94A3B8"),
            CirculatingPiece(id: "GB-coin-1l", countryCode: "GB", category: .coin, denomination: "1", displayValue: "1 £", currencyCode: "GBP", currencySymbol: "£", name: "1 Libra (12 lados)", motif: "Abejas y flora británica", material: "Bimetálica", badgeColorHex: "#F59E0B"),
            CirculatingPiece(id: "GB-coin-2l", countryCode: "GB", category: .coin, denomination: "2", displayValue: "2 £", currencyCode: "GBP", currencySymbol: "£", name: "2 Libras", motif: "Flora británica", material: "Bimetálica", badgeColorHex: "#EAB308"),
            CirculatingPiece(id: "GB-note-5l", countryCode: "GB", category: .banknote, denomination: "5", displayValue: "5 £", currencyCode: "GBP", currencySymbol: "£", name: "Billete de 5 Libras", motif: "Winston Churchill", material: "Polímero", badgeColorHex: "#06B6D4")
        ]
    }

    private static func usSeries() -> [CirculatingPiece] {
        [
            CirculatingPiece(id: "US-coin-1c", countryCode: "US", category: .coin, denomination: "0.01", displayValue: "1¢ Penny", currencyCode: "USD", currencySymbol: "$", name: "1 Cent (Penny)", motif: "Abraham Lincoln", material: "Zinc cobreado", badgeColorHex: "#B45309"),
            CirculatingPiece(id: "US-coin-5c", countryCode: "US", category: .coin, denomination: "0.05", displayValue: "5¢ Nickel", currencyCode: "USD", currencySymbol: "$", name: "5 Cents (Nickel)", motif: "Thomas Jefferson", material: "Cuproníquel", badgeColorHex: "#94A3B8"),
            CirculatingPiece(id: "US-coin-10c", countryCode: "US", category: .coin, denomination: "0.10", displayValue: "10¢ Dime", currencyCode: "USD", currencySymbol: "$", name: "10 Cents (Dime)", motif: "Franklin D. Roosevelt", material: "Cuproníquel", badgeColorHex: "#94A3B8"),
            CirculatingPiece(id: "US-coin-25c", countryCode: "US", category: .coin, denomination: "0.25", displayValue: "25¢ Quarter", currencyCode: "USD", currencySymbol: "$", name: "Quarter Dollar", motif: "George Washington", material: "Cuproníquel", badgeColorHex: "#94A3B8"),
            CirculatingPiece(id: "US-note-1d", countryCode: "US", category: .banknote, denomination: "1", displayValue: "1 $", currencyCode: "USD", currencySymbol: "$", name: "Billete de 1 Dólar", motif: "George Washington", material: "Algodón/Lino", badgeColorHex: "#10B981")
        ]
    }

    private static func egyptSeries() -> [CirculatingPiece] {
        [
            CirculatingPiece(id: "EG-coin-25p", countryCode: "EG", category: .coin, denomination: "0.25", displayValue: "25 Piastras", currencyCode: "EGP", currencySymbol: "E£", name: "25 Piastras", motif: "Águila de Saladino", material: "Acero con baño de latón", badgeColorHex: "#EAB308"),
            CirculatingPiece(id: "EG-coin-50p", countryCode: "EG", category: .coin, denomination: "0.50", displayValue: "50 Piastras", currencyCode: "EGP", currencySymbol: "E£", name: "50 Piastras", motif: "Cleopatra VII", material: "Latón", badgeColorHex: "#EAB308"),
            CirculatingPiece(id: "EG-coin-1l", countryCode: "EG", category: .coin, denomination: "1", displayValue: "1 Libra", currencyCode: "EGP", currencySymbol: "E£", name: "1 Libra Egipcia", motif: "Máscara de Tutankamón", material: "Bimetálica", badgeColorHex: "#F59E0B"),
            CirculatingPiece(id: "EG-note-10l", countryCode: "EG", category: .banknote, denomination: "10", displayValue: "10 E£", currencyCode: "EGP", currencySymbol: "E£", name: "Billete de 10 Libras", motif: "Mezquita Fattah Al-Aleem", material: "Polímero", badgeColorHex: "#F97316")
        ]
    }

    private static func genericSeries(countryCode: String) -> [CirculatingPiece] {
        [
            CirculatingPiece(id: "\(countryCode)-coin-1", countryCode: countryCode, category: .coin, denomination: "1", displayValue: "Unidad 1", currencyCode: countryCode, currencySymbol: "¤", name: "Moneda de 1 Unidad", motif: "Cono circulante", material: "Metal", badgeColorHex: "#F59E0B"),
            CirculatingPiece(id: "\(countryCode)-coin-2", countryCode: countryCode, category: .coin, denomination: "2", displayValue: "Unidad 2", currencyCode: countryCode, currencySymbol: "¤", name: "Moneda de 2 Unidades", motif: "Cono circulante", material: "Bimetálica", badgeColorHex: "#EAB308"),
            CirculatingPiece(id: "\(countryCode)-note-10", countryCode: countryCode, category: .banknote, denomination: "10", displayValue: "Billete 10", currencyCode: countryCode, currencySymbol: "¤", name: "Billete de 10 Unidades", motif: "Papel moneda", material: "Polímero/Algodón", badgeColorHex: "#10B981")
        ]
    }
}
