import Foundation

public struct WeatherResult: Sendable {
    public let tempMin: Double?
    public let tempMax: Double?

    public init(tempMin: Double?, tempMax: Double?) {
        self.tempMin = tempMin
        self.tempMax = tempMax
    }
}

public actor WeatherService {
    public static let shared = WeatherService()

    private let fallbackCoords: [String: (lat: Double, lon: Double)] = [
        "ES": (40.4168, -3.7038),
        "FR": (48.8566, 2.3522),
        "IT": (41.9028, 12.4964),
        "DE": (52.5200, 13.4050),
        "GB": (51.5074, -0.1278),
        "US": (38.9072, -77.0369),
        "JP": (35.6762, 139.6503),
        "EG": (30.0444, 31.2357),
        "PT": (38.7223, -9.1393),
        "GR": (37.9838, 23.7275),
        "NL": (52.3676, 4.9041),
        "CH": (46.9480, 7.4474),
        "AT": (48.2082, 16.3738),
        "MA": (34.0209, -6.8416)
    ]

    private var cache: [String: WeatherResult] = [:]

    private init() {}

    public func fetchWeather(forCity city: String?, countryCode: String, startDate: Date, endDate: Date) async -> WeatherResult {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)

        let cacheKey = "\(countryCode.uppercased())_\(city?.lowercased() ?? "")_\(startStr)_\(endStr)"
        if let cached = cache[cacheKey] {
            return cached
        }

        let (lat, lon) = await resolveCoordinates(city: city, countryCode: countryCode)

        // If trip is in the past, use archive-api; if current/future, use forecast
        let isPast = endDate < Date()
        let baseUrl = isPast
            ? "https://archive-api.open-meteo.com/v1/archive"
            : "https://api.open-meteo.com/v1/forecast"

        guard var components = URLComponents(string: baseUrl) else {
            return WeatherResult(tempMin: nil, tempMax: nil)
        }

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(format: "%.4f", lat)),
            URLQueryItem(name: "longitude", value: String(format: "%.4f", lon)),
            URLQueryItem(name: "start_date", value: startStr),
            URLQueryItem(name: "end_date", value: endStr),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components.url else {
            return WeatherResult(tempMin: nil, tempMax: nil)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return WeatherResult(tempMin: nil, tempMax: nil)
            }

            struct OpenMeteoResponse: Codable {
                struct Daily: Codable {
                    let temperature_2m_max: [Double?]?
                    let temperature_2m_min: [Double?]?
                }
                let daily: Daily?
            }

            let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            let maxTemps = decoded.daily?.temperature_2m_max?.compactMap { $0 } ?? []
            let minTemps = decoded.daily?.temperature_2m_min?.compactMap { $0 } ?? []

            let overallMin = minTemps.min()
            let overallMax = maxTemps.max()

            let result = WeatherResult(
                tempMin: overallMin != nil ? round(overallMin! * 10) / 10 : nil,
                tempMax: overallMax != nil ? round(overallMax! * 10) / 10 : nil
            )
            cache[cacheKey] = result
            return result
        } catch {
            return WeatherResult(tempMin: nil, tempMax: nil)
        }
    }

    private func resolveCoordinates(city: String?, countryCode: String) async -> (lat: Double, lon: Double) {
        let code = countryCode.uppercased()

        if let city = city?.trimmingCharacters(in: .whitespacesAndNewlines), !city.isEmpty {
            guard var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search") else {
                return fallbackCoords[code] ?? (40.4168, -3.7038)
            }
            components.queryItems = [
                URLQueryItem(name: "name", value: city),
                URLQueryItem(name: "count", value: "5"),
                URLQueryItem(name: "language", value: "es"),
                URLQueryItem(name: "format", value: "json")
            ]

            if let url = components.url,
               let (data, _) = try? await URLSession.shared.data(from: url) {
                struct GeocodeResponse: Codable {
                    struct ResultItem: Codable {
                        let latitude: Double
                        let longitude: Double
                        let country_code: String?
                    }
                    let results: [ResultItem]?
                }

                if let decoded = try? JSONDecoder().decode(GeocodeResponse.self, from: data),
                   let results = decoded.results, !results.isEmpty {
                    if let matched = results.first(where: { $0.country_code?.uppercased() == code }) {
                        return (matched.latitude, matched.longitude)
                    }
                    return (results[0].latitude, results[0].longitude)
                }
            }
        }

        return fallbackCoords[code] ?? (40.4168, -3.7038)
    }
}
