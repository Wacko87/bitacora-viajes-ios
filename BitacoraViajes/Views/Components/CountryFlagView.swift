import SwiftUI

public struct CountryFlagView: View {
    public let countryCode: String
    public var fontSize: CGFloat = 20

    public init(countryCode: String, fontSize: CGFloat = 20) {
        self.countryCode = countryCode
        self.fontSize = fontSize
    }

    public var body: some View {
        Text(flagEmoji(for: countryCode))
            .font(.system(size: fontSize))
    }

    private func flagEmoji(for code: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in code.uppercased().unicodeScalars {
            if let scalar = UnicodeScalar(base + v.value) {
                s.unicodeScalars.append(scalar)
            }
        }
        return s.isEmpty ? "🌍" : s
    }
}
