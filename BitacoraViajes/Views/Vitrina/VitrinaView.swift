import SwiftUI
import SwiftData

public struct VitrinaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allArtifacts: [Artifact]

    @State private var viewModel = VitrinaViewModel()
    @State private var showingAddSheet = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Category Chips (Tickets / Postales / Souvenirs)
                    categorySelector

                    // Memories Grid
                    let filtered = viewModel.filteredMemories(allArtifacts)
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
                                            Label("Eliminar Recuerdo", systemImage: "trash")
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
            .navigationTitle("Vitrina de Recuerdos")
            .searchable(text: $viewModel.searchText, prompt: "Buscar ticket, postal, souvenir...")
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
                AddArtifactView(defaultCategory: .ticket)
            }
        }
    }

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip(title: "Todos los recuerdos", category: nil)
                chip(title: "🎟️ Tickets y Entradas", category: .ticket)
                chip(title: "💌 Postales", category: .postcard)
                chip(title: "🎁 Souvenirs", category: .souvenir)
            }
            .padding(.horizontal)
        }
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

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "ticket")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding(.top, 40)
            Text("Vitrina sin recuerdos")
                .font(.headline)
            Text("Guarda entradas de museos, billetes de tren panorámico, postales y recuerdos únicos de vuestras aventuras.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
