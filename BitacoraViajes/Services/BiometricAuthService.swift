import Foundation
import LocalAuthentication
import OSLog

@MainActor
public final class BiometricAuthService {
    public static let shared = BiometricAuthService()

    private let logger = Logger(subsystem: "com.bitacoraviajes.app", category: "Security")
    private let biometricsKey = "bitacora_biometrics_enabled"
    public private(set) var consecutiveFailures: Int = 0

    public var isBiometricsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: biometricsKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: biometricsKey)
            logger.info("Biometric protection setting changed: enabled=\(newValue)")
        }
    }

    private init() {}

    public var isBiometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error {
            logger.warning("Biometric hardware check failed: \(error.localizedDescription)")
        }
        return available
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
        guard isBiometricsEnabled else {
            logger.debug("Biometric check skipped (protection is disabled)")
            return true
        }

        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Desbloquea Bitácora de Viajes para acceder a vuestras crónicas y recuerdos privados."
            )
            if success {
                consecutiveFailures = 0
                logger.info("Biometric authentication successful via \(self.biometricTypeString)")
                return true
            } else {
                handleFailedAttempt(reason: "Policy evaluation returned false")
                return false
            }
        } catch let laError as LAError {
            if laError.code == .userCancel || laError.code == .appCancel {
                logger.notice("Biometric prompt cancelled by user")
            } else {
                handleFailedAttempt(reason: laError.localizedDescription)
            }
            return false
        } catch {
            handleFailedAttempt(reason: error.localizedDescription)
            return false
        }
    }

    private func handleFailedAttempt(reason: String) {
        consecutiveFailures += 1
        logger.error("Security Event: Biometric authentication failed (attempt \(self.consecutiveFailures)): \(reason)")
        if consecutiveFailures >= 3 {
            logger.fault("Security Alert: \(self.consecutiveFailures) consecutive unauthorized unlock attempts detected!")
        }
    }
}
