import SwiftUI
import SwiftData

public struct TripsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var allTrips: [Trip]

    @State private var viewModel = TripsViewModel()
    @State private var showingAddSheet = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Filter Chips
                    filterChipsView

                    // Trips list
                    let filtered = viewModel.filteredTrips(allTrips)
                    if filtered.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filtered) { trip in
                                NavigationLink(value: trip) {
                                    TripCardView(trip: trip)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteTrip(trip)
                                    } label: {
                                        Label("Eliminar Expedición", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Cuaderno de Viajes")
            .searchable(text: $viewModel.searchText, prompt: "Buscar viaje, ciudad o país...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.light)
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.amberAccent)
                    }
                    .accessibilityLabel("Nueva Expedición")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditTripView()
            }
        }
    }

    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(title: "Todos", status: nil)
                ForEach(TripStatus.allCases, id: \.self) { status in
                    chipButton(title: status.localizedTitle, status: status)
                }
            }
            .padding(.horizontal)
        }
    }

    private func chipButton(title: String, status: TripStatus?) -> some View {
        let isSelected = viewModel.selectedFilter == status
        return Button {
            HapticManager.shared.impact(.light)
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedFilter = status
            }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.amberAccent : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? .black : .primary)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.03), radius: 4, x: 0, y: 2)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
                .padding(.top, 40)
            Text("No hay expediciones registradas")
                .font(.headline)
            Text("Pulsa el botón + para comenzar a registrar vuestro próximo destino o memoria de viaje.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private func deleteTrip(_ trip: Trip) {
        HapticManager.shared.notification(.warning)
        modelContext.delete(trip)
    }
}

public struct TripCardView: View {
    public let trip: Trip

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let data = trip.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                } else {
                    LinearGradient(
                        colors: [Color.amberAccent.opacity(0.7), Color.orange.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 160)
                    .overlay(
                        CountryFlagView(countryCode: trip.countryCode, fontSize: 60)
                            .opacity(0.85)
                    )
                }

                // Status chip
                Text(trip.status.localizedTitle)
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(12)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    CountryFlagView(countryCode: trip.countryCode, fontSize: 16)
                    Text(trip.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)
                    Spacer()
                    if let min = trip.tempMin, let max = trip.tempMax {
                        Text("\(Int(min))° / \(Int(max))°C")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                let location = [trip.city, trip.countryCode].compactMap { $0 }.joined(separator: ", ")
                Text(location)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    Label("\(trip.durationInDays) días", systemImage: "calendar")
                    Label("\(trip.artifacts.count) piezas", systemImage: "circle.grid.2x1.fill")
                    Label("\(trip.logs.count) crónicas", systemImage: "text.bubble.fill")
                    Spacer()
                    if let cost = trip.totalCost {
                        Text(String(format: "%.0f %@", cost, trip.costCurrency ?? "EUR"))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.amberAccent)
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            .padding(14)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
