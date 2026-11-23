import Foundation
import LocalAuthentication

@MainActor
public final class BiometricAuthService {
    public static let shared = BiometricAuthService()

    private let biometricsKey = "bitacora_biometrics_enabled"

    public var isBiometricsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: biometricsKey) }
        set { UserDefaults.standard.set(newValue, forKey: biometricsKey) }
    }

    private init() {}

    public var isBiometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public var biometricTypeString: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometría"
        }
    }

    public func authenticate() async -> Bool {
        guard isBiometricsEnabled else { return true }

        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Desbloquea Bitácora de Viajes para acceder a vuestras crónicas y recuerdos privados."
            )
        } catch {
            return false
        }
    }
}
