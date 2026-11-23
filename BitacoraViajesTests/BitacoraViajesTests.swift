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
}
