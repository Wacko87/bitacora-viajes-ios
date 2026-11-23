import Foundation

public struct ServerConfig: Codable, Sendable {
    public var serverURL: String
    public var apiPin: String
    public var isEnabled: Bool

    public init(serverURL: String = "", apiPin: String = "", isEnabled: Bool = false) {
        self.serverURL = serverURL
        self.apiPin = apiPin
        self.isEnabled = isEnabled
    }
}

public actor APISyncService {
    public static let shared = APISyncService()

    private let configKey = "bitacora_server_config"

    private init() {}

    public func loadConfig() -> ServerConfig {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let config = try? JSONDecoder().decode(ServerConfig.self, from: data) else {
            return ServerConfig()
        }
        return config
    }

    public func saveConfig(_ config: ServerConfig) {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }

    public func testConnection(url: String, pin: String) async -> (success: Bool, message: String) {
        guard let server = URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return (false, "URL no válida")
        }
        let pingURL = server.appendingPathComponent("api/auth/status")
        var request = URLRequest(url: pingURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        if !pin.isEmpty {
            request.addValue("Bearer \(pin)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) || http.statusCode == 401 {
                return (true, "Servidor detectado correctamente")
            }
            return (false, "El servidor respondió con código inesperado")
        } catch {
            return (false, "Error al conectar: \(error.localizedDescription)")
        }
    }
}
