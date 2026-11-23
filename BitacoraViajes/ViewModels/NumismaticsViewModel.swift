import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
public final class NumismaticsViewModel {
    public var selectedCategory: ArtifactCategory? = nil
    public var selectedCountryCode: String? = nil
    public var searchText: String = ""
    public var isAddingArtifact: Bool = false

    public init() {}

    public func filteredArtifacts(_ artifacts: [Artifact]) -> [Artifact] {
        artifacts.filter { artifact in
            guard artifact.category.isNumismatic else { return false }

            let matchesCat = selectedCategory == nil || artifact.category == selectedCategory
            let matchesCountry = selectedCountryCode == nil || artifact.countryCode == selectedCountryCode

            let matchesSearch: Bool
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesSearch = true
            } else {
                let term = searchText.lowercased()
                matchesSearch = artifact.title.lowercased().contains(term) ||
                    (artifact.currencyCode?.lowercased().contains(term) ?? false) ||
                    (artifact.denomination?.lowercased().contains(term) ?? false) ||
                    (artifact.story?.lowercased().contains(term) ?? false)
            }

            return matchesCat && matchesCountry && matchesSearch
        }.sorted { $0.createdAt > $1.createdAt }
    }

    public func seriesProgress(countryCode: String, collectedArtifacts: [Artifact]) -> (collected: Int, total: Int, ratio: Double) {
        let officialPieces = CirculatingPiece.series(for: countryCode)
        guard !officialPieces.isEmpty else { return (0, 0, 0.0) }

        let matchingCount = officialPieces.filter { piece in
            collectedArtifacts.contains { art in
                art.countryCode?.uppercased() == countryCode.uppercased() &&
                art.category == piece.category &&
                art.denomination?.replacingOccurrences(of: " ", with: "") == piece.denomination.replacingOccurrences(of: " ", with: "")
            }
        }.count

        let ratio = Double(matchingCount) / Double(officialPieces.count)
        return (matchingCount, officialPieces.count, ratio)
    }
}
