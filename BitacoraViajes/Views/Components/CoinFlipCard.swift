import SwiftUI

public struct CoinFlipCard: View {
    public let artifact: Artifact
    public var cardSize: CGFloat = 170

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
            .rotation3DEffect(
                .degrees(rotationDegrees),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                perspective: 0.8
            )
            .onTapGesture {
                HapticManager.shared.coinFlip()
                withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                    isFlipped.toggle()
                    rotationDegrees = isFlipped ? 180 : 0
                }
            }

            // Info labels
            VStack(spacing: 3) {
                Text(artifact.title)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    if let code = artifact.countryCode {
                        CountryFlagView(countryCode: code, fontSize: 11)
                    }
                    Text(artifact.denomination ?? artifact.category.localizedName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    if let year = artifact.year {
                        Text("• \(String(year))")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
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
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardSize - 16, height: cardSize - 16)
                    .clipShape(artifact.category == .coin ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 12)))
                    .overlay(
                        artifact.category == .coin
                        ? AnyView(Circle().stroke(Color.amberAccent.opacity(0.4), lineWidth: 2))
                        : AnyView(RoundedRectangle(cornerRadius: 12).stroke(Color.amberAccent.opacity(0.4), lineWidth: 2))
                    )
            } else {
                placeholderCapsule(text: "Anverso")
            }
        }
    }

    @ViewBuilder
    private var backView: some View {
        ZStack {
            if let data = artifact.imageBackData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardSize - 16, height: cardSize - 16)
                    .clipShape(artifact.category == .coin ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 12)))
                    .overlay(
                        artifact.category == .coin
                        ? AnyView(Circle().stroke(Color.blue.opacity(0.4), lineWidth: 2))
                        : AnyView(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.4), lineWidth: 2))
                    )
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
                    .foregroundColor(.amberAccent)
                Text(text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: cardSize - 16, height: cardSize - 16)
    }
}

public extension Color {
    static let amberAccent = Color(red: 245/255, green: 158/255, blue: 11/255)
}

public struct AnyShape: Shape, @unchecked Sendable {
    private let pathClosure: @Sendable (CGRect) -> Path

    public init<S: Shape>(_ shape: S) {
        self.pathClosure = { rect in
            shape.path(in: rect)
        }
    }

    public func path(in rect: CGRect) -> Path {
        pathClosure(rect)
    }
}
