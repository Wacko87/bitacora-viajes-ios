import Foundation

public struct CountryInfo: Identifiable, Hashable, Sendable {
    public var id: String { code }
    public let code: String
    public let name: String
    public let flag: String
    public let defaultCurrency: String
    public let currencySymbol: String

    public init(code: String, name: String, flag: String, defaultCurrency: String, currencySymbol: String) {
        self.code = code
        self.name = name
        self.flag = flag
        self.defaultCurrency = defaultCurrency
        self.currencySymbol = currencySymbol
    }

    public static let catalog: [CountryInfo] = [
        CountryInfo(code: "ES", name: "España", flag: "🇪🇸", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "JP", name: "Japón", flag: "🇯🇵", defaultCurrency: "JPY", currencySymbol: "¥"),
        CountryInfo(code: "FR", name: "Francia", flag: "🇫🇷", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "IT", name: "Italia", flag: "🇮🇹", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "GB", name: "Reino Unido", flag: "🇬🇧", defaultCurrency: "GBP", currencySymbol: "£"),
        CountryInfo(code: "US", name: "Estados Unidos", flag: "🇺🇸", defaultCurrency: "USD", currencySymbol: "$"),
        CountryInfo(code: "DE", name: "Alemania", flag: "🇩🇪", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "PT", name: "Portugal", flag: "🇵🇹", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "GR", name: "Grecia", flag: "🇬🇷", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "EG", name: "Egipto", flag: "🇪🇬", defaultCurrency: "EGP", currencySymbol: "E£"),
        CountryInfo(code: "MA", name: "Marruecos", flag: "🇲🇦", defaultCurrency: "MAD", currencySymbol: "DH"),
        CountryInfo(code: "MX", name: "México", flag: "🇲🇽", defaultCurrency: "MXN", currencySymbol: "$"),
        CountryInfo(code: "TH", name: "Tailandia", flag: "🇹🇭", defaultCurrency: "THB", currencySymbol: "฿"),
        CountryInfo(code: "CH", name: "Suiza", flag: "🇨🇭", defaultCurrency: "CHF", currencySymbol: "CHF"),
        CountryInfo(code: "AT", name: "Austria", flag: "🇦🇹", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "NL", name: "Países Bajos", flag: "🇳🇱", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "BE", name: "Bélgica", flag: "🇧🇪", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "IE", name: "Irlanda", flag: "🇮🇪", defaultCurrency: "EUR", currencySymbol: "€"),
        CountryInfo(code: "DK", name: "Dinamarca", flag: "🇩🇰", defaultCurrency: "DKK", currencySymbol: "kr"),
        CountryInfo(code: "SE", name: "Suecia", flag: "🇸🇪", defaultCurrency: "SEK", currencySymbol: "kr"),
        CountryInfo(code: "NO", name: "Noruega", flag: "🇳🇴", defaultCurrency: "NOK", currencySymbol: "kr"),
        CountryInfo(code: "CZ", name: "República Checa", flag: "🇨🇿", defaultCurrency: "CZK", currencySymbol: "Kč"),
        CountryInfo(code: "HU", name: "Hungría", flag: "🇭🇺", defaultCurrency: "HUF", currencySymbol: "Ft"),
        CountryInfo(code: "TR", name: "Turquía", flag: "🇹🇷", defaultCurrency: "TRY", currencySymbol: "₺"),
        CountryInfo(code: "CA", name: "Canadá", flag: "🇨🇦", defaultCurrency: "CAD", currencySymbol: "$"),
        CountryInfo(code: "AU", name: "Australia", flag: "🇦🇺", defaultCurrency: "AUD", currencySymbol: "$"),
        CountryInfo(code: "IS", name: "Islandia", flag: "🇮🇸", defaultCurrency: "ISK", currencySymbol: "kr"),
        CountryInfo(code: "KR", name: "Corea del Sur", flag: "🇰🇷", defaultCurrency: "KRW", currencySymbol: "₩")
    ]

    public static func find(code: String) -> CountryInfo {
        let upper = code.uppercased()
        return catalog.first(where: { $0.code == upper }) ?? CountryInfo(
            code: upper,
            name: upper,
            flag: "🌍",
            defaultCurrency: "EUR",
            currencySymbol: "¤"
        )
    }
}

public typealias CountryCatalog = CountryInfo

