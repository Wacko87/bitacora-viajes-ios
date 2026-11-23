import Foundation
import ActivityKit

public struct TripActivityAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public var cityName: String
        public var countryFlag: String
        public var dayNumber: Int
        public var totalDays: Int
        public var logsCountToday: Int
        public var latestChronicleTitle: String?

        public init(
            cityName: String,
            countryFlag: String,
            dayNumber: Int,
            totalDays: Int,
            logsCountToday: Int,
            latestChronicleTitle: String? = nil
        ) {
            self.cityName = cityName
            self.countryFlag = countryFlag
            self.dayNumber = dayNumber
            self.totalDays = totalDays
            self.logsCountToday = logsCountToday
            self.latestChronicleTitle = latestChronicleTitle
        }
    }

    public var tripTitle: String
    public var destinationCountry: String

    public init(tripTitle: String, destinationCountry: String) {
        self.tripTitle = tripTitle
        self.destinationCountry = destinationCountry
    }
}
