import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
public final class TripsViewModel {
    public var selectedFilter: TripStatus? = nil
    public var searchText: String = ""
    public var isCreatingTrip: Bool = false
    public var isRefreshingWeather: Bool = false

    public init() {}

    public func filteredTrips(_ trips: [Trip]) -> [Trip] {
        trips.filter { trip in
            let matchesFilter: Bool
            if let filter = selectedFilter {
                matchesFilter = trip.status == filter
            } else {
                matchesFilter = true
            }

            let matchesSearch: Bool
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesSearch = true
            } else {
                let term = searchText.lowercased()
                matchesSearch = trip.title.lowercased().contains(term) ||
                    (trip.city?.lowercased().contains(term) ?? false) ||
                    trip.countryCode.lowercased().contains(term)
            }

            return matchesFilter && matchesSearch
        }.sorted { $0.startDate > $1.startDate }
    }

    public func refreshWeather(for trip: Trip) async {
        isRefreshingWeather = true
        defer { isRefreshingWeather = false }

        let result = await WeatherService.shared.fetchWeather(
            forCity: trip.city,
            countryCode: trip.countryCode,
            startDate: trip.startDate,
            endDate: trip.endDate
        )

        trip.tempMin = result.tempMin
        trip.tempMax = result.tempMax
        trip.updatedAt = Date()
    }
}
