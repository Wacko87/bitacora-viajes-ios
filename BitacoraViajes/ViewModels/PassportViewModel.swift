import Foundation
import SwiftData
import SwiftUI

public struct PassportMetrics: Sendable {
    public let totalTrips: Int
    public let uniqueCountriesCount: Int
    public let visitedCountryCodes: [String]
    public let totalDaysOnRoad: Int
    public let totalCoinsCollected: Int
    public let totalBanknotesCollected: Int
    public let totalMemoriesCollected: Int
    public let totalInvestment: Double
}

@Observable
@MainActor
public final class PassportViewModel {
    public init() {}

    public func calculateMetrics(trips: [Trip], artifacts: [Artifact]) -> PassportMetrics {
        let uniqueCodes = Set(trips.map { $0.countryCode.uppercased() })
        let totalDays = trips.reduce(0) { $0 + $1.durationInDays }

        let coins = artifacts.filter { $0.category == .coin }.count
        let banknotes = artifacts.filter { $0.category == .banknote }.count
        let memories = artifacts.filter { !$0.category.isNumismatic }.count
        let totalInvestment = trips.compactMap { $0.totalCost }.reduce(0, +)

        return PassportMetrics(
            totalTrips: trips.count,
            uniqueCountriesCount: uniqueCodes.count,
            visitedCountryCodes: Array(uniqueCodes).sorted(),
            totalDaysOnRoad: totalDays,
            totalCoinsCollected: coins,
            totalBanknotesCollected: banknotes,
            totalMemoriesCollected: memories,
            totalInvestment: totalInvestment
        )
    }
}
