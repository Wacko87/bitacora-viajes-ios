import Foundation
import SwiftData
import SwiftUI

public struct VaultBackupPayload: Codable, Sendable {
    public struct ExportedTrip: Codable, Sendable {
        public let id: String
        public let title: String
        public let countryCode: String
        public let city: String?
        public let startDate: String
        public let endDate: String
        public let status: String
        public let summary: String?
        public let totalCost: Double?
        public let costCurrency: String?
        public let logs: [ExportedLog]
        public let artifacts: [ExportedArtifact]
    }

    public struct ExportedLog: Codable, Sendable {
        public let id: String
        public let dayNumber: Int?
        public let logDate: String
        public let title: String?
        public let notesPartner1: String?
        public let notesPartner2: String?
    }

    public struct ExportedArtifact: Codable, Sendable {
        public let id: String
        public let category: String
        public let title: String
        public let denomination: String?
        public let currencyCode: String?
        public let year: Int?
        public let story: String?
        public let countryCode: String?
    }

    public let exportedAt: String
    public let appVersion: String
    public let trips: [ExportedTrip]
}

public struct BackupJSONFile: Transferable {
    public let data: Data
    public let filename: String

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { file in
            file.data
        }
        .suggestedFileName { file in
            file.filename
        }
    }
}

@MainActor
public final class VaultBackupService {
    public static let shared = VaultBackupService()

    private init() {}

    public func exportVault(trips: [Trip]) -> BackupJSONFile? {
        let formatter = ISO8601DateFormatter()

        let exportedTrips = trips.map { trip in
            let logs = trip.logs.map { log in
                VaultBackupPayload.ExportedLog(
                    id: log.id.uuidString,
                    dayNumber: log.dayNumber,
                    logDate: formatter.string(from: log.logDate),
                    title: log.title,
                    notesPartner1: log.notesPartner1,
                    notesPartner2: log.notesPartner2
                )
            }

            let artifacts = trip.artifacts.map { art in
                VaultBackupPayload.ExportedArtifact(
                    id: art.id.uuidString,
                    category: art.categoryRaw,
                    title: art.title,
                    denomination: art.denomination,
                    currencyCode: art.currencyCode,
                    year: art.year,
                    story: art.story,
                    countryCode: art.countryCode
                )
            }

            return VaultBackupPayload.ExportedTrip(
                id: trip.id.uuidString,
                title: trip.title,
                countryCode: trip.countryCode,
                city: trip.city,
                startDate: formatter.string(from: trip.startDate),
                endDate: formatter.string(from: trip.endDate),
                status: trip.statusRaw,
                summary: trip.summary,
                totalCost: trip.totalCost,
                costCurrency: trip.costCurrency,
                logs: logs,
                artifacts: artifacts
            )
        }

        let payload = VaultBackupPayload(
            exportedAt: formatter.string(from: Date()),
            appVersion: "1.0.0",
            trips: exportedTrips
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(payload) else { return nil }

        let dateStr = Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")
        return BackupJSONFile(data: data, filename: "BitacoraViajes_Backup_\(dateStr).json")
    }
}
