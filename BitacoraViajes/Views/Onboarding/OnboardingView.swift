import SwiftUI

public struct OnboardingView: View {
    @Binding public var isPresented: Bool

    @State private var partner1Name: String = ""
    @State private var partner2Name: String = ""
    @State private var step: Int = 1

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()

                if step == 1 {
                    welcomeStepView
                } else {
                    profileStepView
                }

                Spacer()

                // Bottom Navigation Button
                Button {
                    HapticManager.shared.impact(.medium)
                    if step == 1 {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            step = 2
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    HStack {
                        Text(step == 1 ? "Continuar" : "Comenzar Bitácora")
                            .font(.system(size: 17, weight: .bold))
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.amberAccent)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.amberAccent.opacity(0.35), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color(uiColor: .systemBackground))
        }
    }

    private var welcomeStepView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.amberAccent.opacity(0.15))
                    .frame(width: 110, height: 110)

                Image(systemName: "airplane.circle.fill")
                    .font(.system(size: 68))
                    .foregroundStyle(Color.amberAccent)
            }

            VStack(spacing: 8) {
                Text("Bitácora de Viajes")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Vuestro cuaderno de expediciones, crónicas a dos voces y gabinete numismático 3D.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 14) {
                featureBullet(
                    icon: "text.bubble.fill",
                    title: "Crónicas Diarias a Dos Voces",
                    subtitle: "Registrad cada jornada desde dos perspectivas simultáneas."
                )
                featureBullet(
                    icon: "circle.circle.fill",
                    title: "Gabinete Numismático 3D",
                    subtitle: "Monedas y billetes con giro 180° táctil y conos oficiales."
                )
                featureBullet(
                    icon: "lock.shield.fill",
                    title: "100% Privado y Offline",
                    subtitle: "Tus datos viven en tu dispositivo protegidos por Face ID."
                )
            }
            .padding(.top, 10)
            .padding(.horizontal, 24)
        }
    }

    private var profileStepView: some View {
        VStack(spacing: 22) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.amberAccent)

            VStack(spacing: 6) {
                Text("¿Quiénes sois?")
                    .font(.system(size: 26, weight: .bold))

                Text("Personalizad vuestros nombres para firmar las crónicas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.amberAccent)
                        .frame(width: 36, height: 36)
                        .overlay(Image(systemName: "person.fill").foregroundStyle(.black))

                    TextField("Tu nombre (ej: Laura)", text: $partner1Name)
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 36, height: 36)
                        .overlay(Image(systemName: "person.fill").foregroundStyle(.white))

                    TextField("Nombre de tu pareja (ej: Carlos)", text: $partner2Name)
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func featureBullet(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.amberAccent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func completeOnboarding() {
        let name1 = partner1Name.trimmingCharacters(in: .whitespacesAndNewlines)
        let name2 = partner2Name.trimmingCharacters(in: .whitespacesAndNewlines)

        let p1 = PartnerProfile(
            id: "partner_1",
            name: name1.isEmpty ? "Viajero 1" : name1,
            role: "partner_1",
            avatarColorHex: "#F59E0B"
        )
        let p2 = PartnerProfile(
            id: "partner_2",
            name: name2.isEmpty ? "Viajero 2" : name2,
            role: "partner_2",
            avatarColorHex: "#EC4899"
        )

        if let d1 = try? JSONEncoder().encode(p1) {
            UserDefaults.standard.set(d1, forKey: "partner_1_profile")
        }
        if let d2 = try? JSONEncoder().encode(p2) {
            UserDefaults.standard.set(d2, forKey: "partner_2_profile")
        }

        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        HapticManager.shared.notification(.success)
        isPresented = false
    }
}
