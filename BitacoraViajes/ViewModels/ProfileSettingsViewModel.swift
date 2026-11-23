import Foundation
import SwiftUI

@Observable
@MainActor
public final class ProfileSettingsViewModel {
    public var partner1: PartnerProfile
    public var partner2: PartnerProfile
    public var serverConfig: ServerConfig
    public var connectionTestMessage: String?
    public var isTestingConnection: Bool = false

    private let p1Key = "partner_1_profile"
    private let p2Key = "partner_2_profile"

    public init() {
        if let data1 = UserDefaults.standard.data(forKey: p1Key),
           let p1 = try? JSONDecoder().decode(PartnerProfile.self, from: data1) {
            self.partner1 = p1
        } else {
            self.partner1 = .defaultPartner1
        }

        if let data2 = UserDefaults.standard.data(forKey: p2Key),
           let p2 = try? JSONDecoder().decode(PartnerProfile.self, from: data2) {
            self.partner2 = p2
        } else {
            self.partner2 = .defaultPartner2
        }

        self.serverConfig = ServerConfig()
    }

    public func loadSettings() async {
        self.serverConfig = await APISyncService.shared.loadConfig()
    }

    public func saveProfiles() {
        if let d1 = try? JSONEncoder().encode(partner1) {
            UserDefaults.standard.set(d1, forKey: p1Key)
        }
        if let d2 = try? JSONEncoder().encode(partner2) {
            UserDefaults.standard.set(d2, forKey: p2Key)
        }
    }

    public func saveServerConfig() async {
        await APISyncService.shared.saveConfig(serverConfig)
    }

    public func testServerConnection() async {
        isTestingConnection = true
        defer { isTestingConnection = false }
        let (success, msg) = await APISyncService.shared.testConnection(
            url: serverConfig.serverURL,
            pin: serverConfig.apiPin
        )
        connectionTestMessage = success ? "✅ \(msg)" : "⚠️ \(msg)"
    }
}
