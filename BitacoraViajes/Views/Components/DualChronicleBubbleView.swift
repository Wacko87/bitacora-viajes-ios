import SwiftUI

public struct DualChronicleBubbleView: View {
    public let partnerName: String
    public let partnerRole: String
    public let avatarColor: Color
    public let notes: String?
    public let placeholder: String

    public init(
        partnerName: String,
        partnerRole: String,
        avatarColor: Color,
        notes: String?,
        placeholder: String = "Sin crónica registrada aún..."
    ) {
        self.partnerName = partnerName
        self.partnerRole = partnerRole
        self.avatarColor = avatarColor
        self.notes = notes
        self.placeholder = placeholder
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Text(String(partnerName.prefix(1)).uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    )

                Text(partnerName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Text(partnerRole == "partner_1" ? "Voz 1" : "Voz 2")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(avatarColor.opacity(0.15))
                    .foregroundColor(avatarColor)
                    .clipShape(Capsule())
            }

            if let content = notes, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .lineSpacing(3)
            } else {
                Text(placeholder)
                    .font(.system(size: 13, weight: .regular))
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(avatarColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
