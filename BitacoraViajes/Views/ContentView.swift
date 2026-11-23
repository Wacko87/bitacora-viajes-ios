import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingOnboarding: Bool = false
    @State private var selectedTab: Int = 0
    @State private var isUnlocked: Bool = !BiometricAuthService.shared.isBiometricsEnabled

    public init() {}

    public var body: some View {
        Group {
            if isUnlocked {
                mainTabView
            } else {
                lockScreenView
            }
        }
        .task {
            BitacoraViajesApp.seedInitialDataIfNeeded(context: modelContext)
            if !hasCompletedOnboarding {
                showingOnboarding = true
            }
            if BiometricAuthService.shared.isBiometricsEnabled {
                await authenticate()
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView(isPresented: $showingOnboarding)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background && BiometricAuthService.shared.isBiometricsEnabled {
                isUnlocked = false
            } else if newPhase == .active && !isUnlocked && BiometricAuthService.shared.isBiometricsEnabled {
                Task { await authenticate() }
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            TripsListView()
                .tabItem {
                    Label("Viajes", systemImage: "airplane")
                }
                .tag(0)

            NumismaticCabinetView()
                .tabItem {
                    Label("Numismática", systemImage: "circle.circle.fill")
                }
                .tag(1)

            VitrinaView()
                .tabItem {
                    Label("Vitrina", systemImage: "ticket.fill")
                }
                .tag(2)

            PassportView()
                .tabItem {
                    Label("Pasaporte", systemImage: "globe.europe.africa.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.amberAccent)
    }

    private var lockScreenView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.amberAccent)

            VStack(spacing: 8) {
                Text("Bitácora Protegida")
                    .font(.system(size: 24, weight: .bold))

                Text("Autentícate para acceder a vuestras crónicas y recuerdos privados de viaje.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task { await authenticate() }
            } label: {
                Label("Desbloquear con \(BiometricAuthService.shared.biometricTypeString)", systemImage: "faceid")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.amberAccent)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }

    private func authenticate() async {
        let success = await BiometricAuthService.shared.authenticate()
        if success {
            HapticManager.shared.notification(.success)
            withAnimation(.easeInOut(duration: 0.25)) {
                isUnlocked = true
            }
        }
    }
}
