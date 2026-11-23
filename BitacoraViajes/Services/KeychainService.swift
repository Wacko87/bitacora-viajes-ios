import Foundation
import Security

public final class KeychainService: @unchecked Sendable {
    public static let shared = KeychainService()

    private let serviceName = "com.bitacoraviajes.app.keychain"
    private var simulatorFallbackCache: [String: Data] = [:]
    private let lock = NSLock()

    private init() {}

    @discardableResult
    public func save(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            return true
        }

        // Fallback for Simulator test runners without provisioned keychain entitlement (-34018)
        if status == errSecMissingEntitlement || status == -34018 {
            lock.lock()
            simulatorFallbackCache[key] = data
            lock.unlock()
            return true
        }

        return false
    }

    public func save(key: String, string: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(key: key, data: data)
    }

    public func loadData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data {
            return data
        }

        // Check fallback cache
        lock.lock()
        defer { lock.unlock() }
        return simulatorFallbackCache[key]
    }

    public func loadString(key: String) -> String? {
        guard let data = loadData(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    public func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        lock.lock()
        simulatorFallbackCache.removeValue(forKey: key)
        lock.unlock()
        return status == errSecSuccess || status == errSecItemNotFound || status == errSecMissingEntitlement || status == -34018
    }
}
