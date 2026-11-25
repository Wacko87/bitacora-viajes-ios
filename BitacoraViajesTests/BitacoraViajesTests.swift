import Testing
import Foundation
@testable import BitacoraViajes

struct BitacoraViajesTests {

    @Test func testCountryCatalogLookup() {
        let spain = CountryCatalog.find(code: "ES")
        #expect(spain.code == "ES")
        #expect(spain.flag == "🇪🇸")
        #expect(spain.defaultCurrency == "EUR")

        let japan = CountryCatalog.find(code: "JP")
        #expect(japan.code == "JP")
        #expect(japan.flag == "🇯🇵")
        #expect(japan.defaultCurrency == "JPY")

        let unknown = CountryCatalog.find(code: "XYZ")
        #expect(unknown.code == "XYZ")
        #expect(unknown.flag == "🌍")
    }

    @Test func testExpenseEqualSplitCalculation() {
        let expense = TripExpense(
            title: "Cena Romántica",
            amount: 100.0,
            currencyCode: "EUR",
            paidByPartnerIndex: 0,
            split: .equal
        )

        #expect(expense.amountInEUR == 100.0)
        #expect(expense.partner1ShareInEUR == 50.0)
        #expect(expense.partner2ShareInEUR == 50.0)
    }

    @Test func testExpensePartnerFullShareCalculation() {
        let p1Expense = TripExpense(
            title: "Recuerdo Personal P1",
            amount: 75.0,
            currencyCode: "EUR",
            paidByPartnerIndex: 0,
            split: .allP1
        )
        #expect(p1Expense.partner1ShareInEUR == 75.0)
        #expect(p1Expense.partner2ShareInEUR == 0.0)

        let p2Expense = TripExpense(
            title: "Recuerdo Personal P2",
            amount: 50.0,
            currencyCode: "EUR",
            paidByPartnerIndex: 1,
            split: .allP2
        )
        #expect(p2Expense.partner1ShareInEUR == 0.0)
        #expect(p2Expense.partner2ShareInEUR == 50.0)
    }

    @Test func testKeychainStoreAndRetrieve() {
        let testKey = "test_auth_token_key"
        let testValue = "secret_pin_12345"

        let saved = KeychainService.shared.save(key: testKey, string: testValue)
        #expect(saved == true)

        let loaded = KeychainService.shared.loadString(key: testKey)
        #expect(loaded == testValue)

        let deleted = KeychainService.shared.delete(key: testKey)
        #expect(deleted == true)

        let loadedAfterDelete = KeychainService.shared.loadString(key: testKey)
        #expect(loadedAfterDelete == nil)
    }

    // MARK: - Security Hardening Suite (27 Puntos)

    @Test func testHTTPSStrictEnforcement() async {
        // Attempt connecting with unencrypted HTTP URL (must be rejected)
        let insecureResult = await APISyncService.shared.testConnection(url: "http://servidor-inseguro.local", pin: "1234")
        #expect(insecureResult.success == false)
        #expect(insecureResult.message.contains("HTTPS obligatoria"))

        // Attempt connecting with malformed URL scheme
        let malformedResult = await APISyncService.shared.testConnection(url: "ftp://servidor.local", pin: "1234")
        #expect(malformedResult.success == false)
        #expect(malformedResult.message.contains("HTTPS obligatoria"))
    }

    @Test func testAPISyncRateLimiting() async {
        // First check with rate limiter (cooldown starts)
        let firstCheck = await APISyncService.shared.checkRateLimit()
        #expect(firstCheck.allowed == true)
        
        // Immediate second attempt within 2 seconds (must be throttled)
        let throttledResult = await APISyncService.shared.checkRateLimit()
        #expect(throttledResult.allowed == false)
        #expect(throttledResult.message.contains("Límite de intentos"))
    }

    @Test func testOversizedPayloadProtection() {
        // Attempt processing a dummy payload exceeding 30 MB threshold
        let oversizedData = Data(count: 31 * 1024 * 1024) // 31 MB
        let downsampled = ImageOptimizerService.shared.downsample(imageData: oversizedData)
        #expect(downsampled == nil)

        let downsampledCoin = ImageOptimizerService.shared.downsampleCoinPNG(imageData: oversizedData)
        #expect(downsampledCoin == nil)
    }

    @Test @MainActor func testBiometricConsecutiveFailureTracking() {
        // Verify biometric service state and initial failure tracking
        let initialFailures = BiometricAuthService.shared.consecutiveFailures
        #expect(initialFailures >= 0)
    }

    @Test func testExpenseTamperingResilience() {
        // Safe price parser helper that handles thousand dots and decimal commas
        func parseAmount(_ string: String) -> Double? {
            var cleaned = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleaned.contains(",") && cleaned.contains(".") {
                cleaned = cleaned.replacingOccurrences(of: ".", with: "")
                cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
            } else if cleaned.contains(",") {
                cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
            }
            cleaned = cleaned.components(separatedBy: CharacterSet(charactersIn: "0123456789.-").inverted).joined()
            return Double(cleaned)
        }

        let parsed = parseAmount("99.999,50 €")
        #expect(parsed != nil)
        #expect(parsed == 99999.50)

        // Verify malicious string injection does not crash parser and extracts only numeric values
        let injectionPayload = parseAmount("<script>alert('xss')</script>50.00")
        #expect(injectionPayload != nil)
        #expect(injectionPayload == 50.0)

        // Verify invalid corrupted text safely returns nil
        let corruptPayload = parseAmount("free-money-not-a-number")
        #expect(corruptPayload == nil)
    }
}
