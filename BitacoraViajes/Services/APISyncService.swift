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
    private let keychainPinKey = "bitacora_server_api_pin"

    private init() {}

    public func loadConfig() -> ServerConfig {
        let securePin = KeychainService.shared.loadString(key: keychainPinKey) ?? ""
        guard let data = UserDefaults.standard.data(forKey: configKey),
              var config = try? JSONDecoder().decode(ServerConfig.self, from: data) else {
            return ServerConfig(serverURL: "", apiPin: securePin, isEnabled: false)
        }
        config.apiPin = securePin
        return config
    }

    public func saveConfig(_ config: ServerConfig) {
        // Store sensitive token securely in Keychain
        if !config.apiPin.isEmpty {
            KeychainService.shared.save(key: keychainPinKey, string: config.apiPin)
        } else {
            KeychainService.shared.delete(key: keychainPinKey)
        }

        // Store non-sensitive metadata in UserDefaults with sanitized PIN
        var sanitizedConfig = config
        sanitizedConfig.apiPin = "" // Stripped from UserDefaults
        if let data = try? JSONEncoder().encode(sanitizedConfig) {
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
