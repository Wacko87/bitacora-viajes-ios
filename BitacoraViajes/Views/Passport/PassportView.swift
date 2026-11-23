import SwiftUI
import SwiftData
import MapKit

public struct PassportView: View {
    @Query private var trips: [Trip]
    @Query private var artifacts: [Artifact]

    @State private var viewModel = PassportViewModel()
    @State private var mapPosition: MapCameraPosition = .automatic

    private var partner1: PartnerProfile {
        if let d = UserDefaults.standard.data(forKey: "partner_1_profile"),
           let p = try? JSONDecoder().decode(PartnerProfile.self, from: d) {
            return p
        }
        return .defaultPartner1
    }

    private var partner2: PartnerProfile {
        if let d = UserDefaults.standard.data(forKey: "partner_2_profile"),
           let p = try? JSONDecoder().decode(PartnerProfile.self, from: d) {
            return p
        }
        return .defaultPartner2
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Passport Cover Card
                    passportHeaderCard

                    // Quick Stats Grid
                    let metrics = viewModel.calculateMetrics(trips: trips, artifacts: artifacts)
                    statsGrid(metrics: metrics)

                    // Visited Countries Visa Stamps
                    visaStampsSection(metrics: metrics)

                    // Map Section
                    mapSection
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Pasaporte de Pareja")
        }
    }

    private var passportHeaderCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PASAPORTE OFICIAL DE EXPEDICIÓN")
                        .font(.system(size: 11, weight: .black))
                        .tracking(1.5)
                        .foregroundColor(.amberAccent)
                    Text("\(partner1.name) & \(partner2.name)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.amberAccent.opacity(0.8))
            }

            Divider()
                .background(Color.white.opacity(0.2))

            HStack {
                Label("Bitácora Privada", systemImage: "lock.shield.fill")
                Spacer()
                Label("Expediciones activas", systemImage: "airplane")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.25), Color(red: 0.05, green: 0.08, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.amberAccent.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
        .padding(.horizontal)
    }

    private func statsGrid(metrics: PassportMetrics) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCardView(
                title: "Países Visitados",
                value: "\(metrics.uniqueCountriesCount)",
                icon: "flag.fill",
                color: .amberAccent
            )
            StatCardView(
                title: "Días en Ruta",
                value: "\(metrics.totalDaysOnRoad)",
                icon: "calendar",
                color: .blue
            )
            StatCardView(
                title: "Monedas & Billetes",
                value: "\(metrics.totalCoinsCollected + metrics.totalBanknotesCollected)",
                icon: "circle.grid.2x1.fill",
                color: .orange
            )
            StatCardView(
                title: "Inversión Viajera",
                value: String(format: "%.0f €", metrics.totalInvestment),
                icon: "creditcard.fill",
                color: .green
            )
        }
        .padding(.horizontal)
    }

    private func visaStampsSection(metrics: PassportMetrics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sellos de Visados Obtenidos")
                .font(.system(size: 15, weight: .bold))
                .padding(.horizontal)

            if metrics.visitedCountryCodes.isEmpty {
                Text("No hay sellos de visado aún. Completad vuestro primer viaje para sellar el pasaporte.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(metrics.visitedCountryCodes, id: \.self) { code in
                            visaStampView(countryCode: code)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func visaStampView(countryCode: String) -> some View {
        VStack(spacing: 6) {
            CountryFlagView(countryCode: countryCode, fontSize: 32)
            Text(countryCode)
                .font(.system(size: 12, weight: .black))
                .tracking(2)
                .foregroundColor(.amberAccent)
            Text("VISITADO")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(width: 100, height: 100)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.amberAccent.opacity(0.4), lineWidth: 1)
        )
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mapa de Expediciones")
                .font(.system(size: 15, weight: .bold))
                .padding(.horizontal)

            Map(position: $mapPosition)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
        }
    }
}
