import SwiftUI

public struct CoinFlipCard: View {
    public let artifact: Artifact
    public var cardSize: CGFloat = 170

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFlipped: Bool = false
    @State private var rotationDegrees: Double = 0

    public init(artifact: Artifact, cardSize: CGFloat = 170) {
        self.artifact = artifact
        self.cardSize = cardSize
    }

    public var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Front Side
                frontView
                    .opacity(rotationDegrees < 90 ? 1 : 0)

                // Back Side
                backView
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(rotationDegrees >= 90 ? 1 : 0)
            }
            .frame(width: cardSize, height: cardSize)
            .compositingGroup()
            .rotation3DEffect(
                .degrees(rotationDegrees),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                perspective: 0.8
            )
            .onTapGesture {
                HapticManager.shared.coinFlip()
                if reduceMotion {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isFlipped.toggle()
                        rotationDegrees = isFlipped ? 180 : 0
                    }
                } else {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                        isFlipped.toggle()
                        rotationDegrees = isFlipped ? 180 : 0
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(artifact.title), \(artifact.category.localizedName). Toca dos veces para voltear.")

            // Info labels
            VStack(spacing: 3) {
                Text(artifact.title)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    if let code = artifact.countryCode {
                        CountryFlagView(countryCode: code, fontSize: 11)
                    }
                    Text(artifact.denomination ?? artifact.category.localizedName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    if let year = artifact.year {
                        Text("• \(String(year))")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: cardSize)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    @ViewBuilder
    private var frontView: some View {
        ZStack {
            if let data = artifact.imageFrontData, let uiImage = UIImage(data: data) {
                if artifact.category == .coin {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardSize - 16, height: cardSize - 16)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.amberAccent.opacity(0.4), lineWidth: 2))
                } else {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardSize - 16, height: cardSize - 16)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.amberAccent.opacity(0.4), lineWidth: 2))
                }
            } else {
                placeholderCapsule(text: "Anverso")
            }
        }
    }

    @ViewBuilder
    private var backView: some View {
        ZStack {
            if let data = artifact.imageBackData, let uiImage = UIImage(data: data) {
                if artifact.category == .coin {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardSize - 16, height: cardSize - 16)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue.opacity(0.4), lineWidth: 2))
                } else {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardSize - 16, height: cardSize - 16)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.4), lineWidth: 2))
                }
            } else {
                placeholderCapsule(text: "Reverso sin foto")
            }
        }
    }

    private func placeholderCapsule(text: String) -> some View {
        ZStack {
            if artifact.category == .coin {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.amberAccent.opacity(0.25), Color.amberAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(Circle().stroke(Color.amberAccent.opacity(0.3), lineWidth: 1.5))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .tertiarySystemFill))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))
            }

            VStack(spacing: 6) {
                Image(systemName: artifact.category.systemIcon)
                    .font(.system(size: 32))
                    .foregroundStyle(Color.amberAccent)
                Text(text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: cardSize - 16, height: cardSize - 16)
    }
}

public extension Color {
    static let amberAccent = Color(red: 245/255, green: 158/255, blue: 11/255)
}
