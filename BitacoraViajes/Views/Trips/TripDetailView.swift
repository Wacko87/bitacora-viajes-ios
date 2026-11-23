import SwiftUI
import SwiftData

public struct TripDetailView: View {
    @Bindable public var trip: Trip
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: Int = 0
    @State private var showingAddLogSheet: Bool = false
    @State private var showingExportSheet: Bool = false
    @State private var showingAddArtifactSheet: Bool = false
    @State private var isRefreshingWeather: Bool = false

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

    public init(trip: Trip) {
        self.trip = trip
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Trip Header Banner
                headerBanner

                // Segment Control
                Picker("Pestañas", selection: $selectedTab) {
                    Text("Crónica").tag(0)
                    Text("Numismática").tag(1)
                    Text("Vitrina").tag(2)
                    Text("Detalles").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Tab Content
                switch selectedTab {
                case 0:
                    chroniclesTab
                case 1:
                    numismaticsTab
                case 2:
                    vitrinaTab
                default:
                    detailsTab
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(trip.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Label("Exportar Libro Editorial (PDF)", systemImage: "doc.richtext")
                    }

                    Button {
                        Task { await refreshWeather() }
                    } label: {
                        Label("Actualizar Clima Histórico", systemImage: "cloud.sun")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.amberAccent)
                }
            }
        }
        .sheet(isPresented: $showingAddLogSheet) {
            AddTripLogView(trip: trip, nextDayNumber: trip.logs.count + 1)
        }
        .sheet(isPresented: $showingAddArtifactSheet) {
            AddArtifactView(preselectedTrip: trip)
        }
        .sheet(isPresented: $showingExportSheet) {
            TripBookExportView(trip: trip, partner1: partner1, partner2: partner2)
        }
    }

    private var headerBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                if let data = trip.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } else {
                    LinearGradient(
                        colors: [Color.amberAccent.opacity(0.8), Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 200)
                    .overlay(CountryFlagView(countryCode: trip.countryCode, fontSize: 80).opacity(0.8))
                }

                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        CountryFlagView(countryCode: trip.countryCode, fontSize: 18)
                        Text([trip.city, trip.countryCode].compactMap { $0 }.joined(separator: ", "))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) — \(trip.endDate.formatted(date: .abbreviated, time: .omitted)) (\(trip.durationInDays) días)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal)

            // Weather & Cost Quick Pill
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "thermometer.sun.fill")
                        .foregroundColor(.amberAccent)
                    if let min = trip.tempMin, let max = trip.tempMax {
                        Text("\(Int(min))° a \(Int(max))°C")
                            .font(.system(size: 13, weight: .semibold))
                    } else {
                        Text("Clima no sincronizado")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if let cost = trip.totalCost {
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.green)
                        Text(String(format: "%.0f %@", cost, trip.costCurrency ?? "EUR"))
                            .font(.system(size: 13, weight: .bold))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var chroniclesTab: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Crónicas Diarias a Dos Voces")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button {
                    HapticManager.shared.impact(.light)
                    showingAddLogSheet = true
                } label: {
                    Label("Añadir Jornada", systemImage: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.amberAccent)
                }
            }
            .padding(.horizontal)

            let sortedLogs = trip.logs.sorted { ($0.dayNumber ?? 0) < ($1.dayNumber ?? 0) }
            if sortedLogs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                    Text("Aún no habéis escrito crónicas de este viaje")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                ForEach(sortedLogs) { log in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Día \(log.dayNumber ?? 1)")
                                .font(.system(size: 12, weight: .black))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.amberAccent.opacity(0.2))
                                .foregroundColor(.amberAccent)
                                .clipShape(Capsule())

                            if let title = log.title, !title.isEmpty {
                                Text(title)
                                    .font(.system(size: 15, weight: .bold))
                            }
                            Spacer()
                            Text(log.logDate.formatted(date: .numeric, time: .omitted))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        // Partner 1 Bubble
                        DualChronicleBubbleView(
                            partnerName: partner1.name,
                            partnerRole: "partner_1",
                            avatarColor: Color(hex: partner1.avatarColorHex) ?? .amberAccent,
                            notes: log.notesPartner1,
                            placeholder: "Sin notas de \(partner1.name) para este día..."
                        )

                        // Partner 2 Bubble
                        DualChronicleBubbleView(
                            partnerName: partner2.name,
                            partnerRole: "partner_2",
                            avatarColor: Color(hex: partner2.avatarColorHex) ?? .pink,
                            notes: log.notesPartner2,
                            placeholder: "Sin notas de \(partner2.name) para este día..."
                        )
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
            }
        }
    }

    private var numismaticsTab: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Monedas y Billetes del Viaje")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button {
                    showingAddArtifactSheet = true
                } label: {
                    Label("Añadir Pieza", systemImage: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.amberAccent)
                }
            }
            .padding(.horizontal)

            let numismatics = trip.artifacts.filter { $0.category.isNumismatic }
            if numismatics.isEmpty {
                Text("No hay piezas numismáticas vinculadas a esta expedición.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(numismatics) { artifact in
                        CoinFlipCard(artifact: artifact, cardSize: 155)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var vitrinaTab: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recuerdos, Tickets y Souvenirs")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button {
                    showingAddArtifactSheet = true
                } label: {
                    Label("Añadir Recuerdo", systemImage: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.amberAccent)
                }
            }
            .padding(.horizontal)

            let memories = trip.artifacts.filter { !$0.category.isNumismatic }
            if memories.isEmpty {
                Text("No hay tickets o souvenirs registrados para este viaje.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(memories) { artifact in
                        CoinFlipCard(artifact: artifact, cardSize: 155)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var detailsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let summary = trip.summary, !summary.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Resumen General")
                        .font(.system(size: 14, weight: .bold))
                    Text(summary)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Presupuesto e Inclusiones")
                    .font(.system(size: 14, weight: .bold))

                if let cost = trip.totalCost {
                    Text(String(format: "Inversión Total: %.2f %@", cost, trip.costCurrency ?? "EUR"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.amberAccent)
                }

                if let inc = trip.inclusions, !inc.isEmpty {
                    Text("Incluye: \(inc)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                if let notes = trip.costNotes, !notes.isEmpty {
                    Text("Notas: \(notes)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
    }

    private func refreshWeather() async {
        isRefreshingWeather = true
        defer { isRefreshingWeather = false }
        let result = await WeatherService.shared.fetchWeather(
            forCity: trip.city,
            countryCode: trip.countryCode,
            startDate: trip.startDate,
            endDate: trip.endDate
        )
        trip.tempMin = result.tempMin
        trip.tempMax = result.tempMax
        HapticManager.shared.notification(.success)
    }
}

public extension Color {
    init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        guard cleanHex.count == 6, let rgbValue = UInt64(cleanHex, radix: 16) else {
            return nil
        }
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
