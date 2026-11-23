import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
public final class VitrinaViewModel {
    public var selectedCategory: ArtifactCategory? = nil
    public var searchText: String = ""
    public var isAddingMemory: Bool = false

    public init() {}

    public func filteredMemories(_ artifacts: [Artifact]) -> [Artifact] {
        artifacts.filter { artifact in
            guard !artifact.category.isNumismatic else { return false }

            let matchesCat = selectedCategory == nil || artifact.category == selectedCategory

            let matchesSearch: Bool
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesSearch = true
            } else {
                let term = searchText.lowercased()
                matchesSearch = artifact.title.lowercased().contains(term) ||
                    (artifact.story?.lowercased().contains(term) ?? false) ||
                    (artifact.countryCode?.lowercased().contains(term) ?? false)
            }

            return matchesCat && matchesSearch
        }.sorted { $0.createdAt > $1.createdAt }
    }
}
