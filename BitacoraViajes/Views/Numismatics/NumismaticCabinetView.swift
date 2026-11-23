import SwiftUI
import SwiftData
import TipKit

public struct NumismaticCabinetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allArtifacts: [Artifact]

    @State private var viewModel = NumismaticsViewModel()
    @State private var showingAddSheet = false
    private let coinFlipTip = CoinFlipTip()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // TipKit Onboarding
                    TipView(coinFlipTip, arrowEdge: .bottom)
                        .padding(.horizontal)

                    // Category Chips (Todas / Monedas / Billetes)
                    categorySelector

                    // Circulating Series Progress Carousel
                    officialSeriesCarousel

                    // Pieces Grid
                    let filtered = viewModel.filteredArtifacts(allArtifacts)
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filtered) { artifact in
                                CoinFlipCard(artifact: artifact, cardSize: 160)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            modelContext.delete(artifact)
                                        } label: {
                                            Label("Eliminar Pieza", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Gabinete Numismático 3D")
            .searchable(text: $viewModel.searchText, prompt: "Buscar moneda, billete, denominación...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.light)
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.amberAccent)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddArtifactView(defaultCategory: .coin)
            }
        }
    }

    private var categorySelector: some View {
        HStack(spacing: 10) {
            chip(title: "Todas las piezas", category: nil)
            chip(title: "🪙 Monedas", category: .coin)
            chip(title: "💵 Billetes", category: .banknote)
            Spacer()
        }
        .padding(.horizontal)
    }

    private func chip(title: String, category: ArtifactCategory?) -> some View {
        let isSelected = viewModel.selectedCategory == category
        return Button {
            HapticManager.shared.impact(.light)
            withAnimation {
                viewModel.selectedCategory = category
            }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.amberAccent : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .black : .primary)
                .clipShape(Capsule())
        }
    }

    private var officialSeriesCarousel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cono Monetario Oficial por País")
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    seriesCard(countryCode: "ES", countryName: "Eurozona")
                    seriesCard(countryCode: "JP", countryName: "Japón (Yen)")
                    seriesCard(countryCode: "GB", countryName: "Reino Unido")
                    seriesCard(countryCode: "US", countryName: "Estados Unidos")
                    seriesCard(countryCode: "EG", countryName: "Egipto")
                }
                .padding(.horizontal)
            }
        }
    }

    private func seriesCard(countryCode: String, countryName: String) -> some View {
        let progress = viewModel.seriesProgress(countryCode: countryCode, collectedArtifacts: allArtifacts)
        let percent = Int(progress.ratio * 100)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                CountryFlagView(countryCode: countryCode, fontSize: 16)
                Text(countryName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
            }

            ProgressView(value: progress.ratio)
                .tint(progress.ratio == 1.0 ? .green : .amberAccent)

            HStack {
                Text("\(progress.collected) / \(progress.total) piezas")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(percent)%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(progress.ratio == 1.0 ? .green : .amberAccent)
            }
        }
        .padding(12)
        .frame(width: 175)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "circle.circle")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding(.top, 40)
            Text("Gabinete numismático vacío")
                .font(.headline)
            Text("Pulsa + para registrar vuestras primeras monedas o billetes con giro 3D táctil.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
