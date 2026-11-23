import SwiftUI
import SwiftData
import PhotosUI

public struct AddArtifactView: View {
    public var preselectedTrip: Trip? = nil
    public var defaultCategory: ArtifactCategory = .coin

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var availableTrips: [Trip]

    @State private var category: ArtifactCategory
    @State private var title: String = ""
    @State private var selectedCountry: CountryInfo = CountryCatalog.find(code: "ES")
    @State private var showingCountryPicker: Bool = false
    @State private var showingCoinScanner: Bool = false
    @State private var currencyCode: String = "EUR"
    @State private var denomination: String = "1"
    @State private var yearString: String = ""
    @State private var story: String = ""
    @State private var selectedTripId: UUID? = nil

    @State private var frontPhotoItem: PhotosPickerItem? = nil
    @State private var backPhotoItem: PhotosPickerItem? = nil
    @State private var imageFrontData: Data? = nil
    @State private var imageBackData: Data? = nil

    public init(preselectedTrip: Trip? = nil, defaultCategory: ArtifactCategory = .coin) {
        self.preselectedTrip = preselectedTrip
        self.defaultCategory = defaultCategory
        _category = State(initialValue: defaultCategory)
        if let trip = preselectedTrip {
            _selectedTripId = State(initialValue: trip.id)
            _selectedCountry = State(initialValue: CountryCatalog.find(code: trip.countryCode))
            _currencyCode = State(initialValue: CountryCatalog.find(code: trip.countryCode).defaultCurrency)
        }
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Clasificación") {
                    Picker("Tipo de Objeto", selection: $category) {
                        ForEach(ArtifactCategory.allCases) { cat in
                            Label(cat.localizedName, systemImage: cat.systemIcon).tag(cat)
                        }
                    }

                    TextField("Título de la pieza o recuerdo", text: $title)

                    Button {
                        showingCountryPicker = true
                    } label: {
                        HStack {
                            Text("País de Origen")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(selectedCountry.flag) \(selectedCountry.name)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    if !availableTrips.isEmpty {
                        Picker("Viaje Vinculado", selection: $selectedTripId) {
                            Text("Sin vincular a viaje").tag(UUID?.none)
                            ForEach(availableTrips) { t in
                                Text(t.title).tag(UUID?.some(t.id))
                            }
                        }
                    }
                }

                if category.isNumismatic {
                    Section("Datos Numismáticos") {
                        HStack {
                            TextField("Valor Facial (ej: 1, 50, 0.20)", text: $denomination)
                            Text(currencyCode)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.amberAccent)
                                .frame(width: 70)
                        }
                        TextField("Año de Acuñación / Emisión (opcional)", text: $yearString)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Fotografías de la Pieza (Cápsula 3D)") {
                    Button {
                        showingCoinScanner = true
                    } label: {
                        Label("Escanear Moneda Circular con IA", systemImage: "viewfinder.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.amberAccent)
                    }

                    // Front Photo
                    PhotosPicker(selection: $frontPhotoItem, matching: .images) {
                        HStack {
                            Label("Foto Anverso", systemImage: "circle.circle")
                            Spacer()
                            if let data = imageFrontData, let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Text("Añadir").foregroundStyle(Color.amberAccent)
                            }
                        }
                    }
                    .onChange(of: frontPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                let optimized = ImageOptimizerService.shared.downsampleCoinPNG(imageData: data, maxDimension: 600) ?? data
                                imageFrontData = optimized
                            }
                        }
                    }

                    // Back Photo
                    PhotosPicker(selection: $backPhotoItem, matching: .images) {
                        HStack {
                            Label("Foto Reverso", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            if let data = imageBackData, let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Text("Añadir").foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onChange(of: backPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                let optimized = ImageOptimizerService.shared.downsampleCoinPNG(imageData: data, maxDimension: 600) ?? data
                                imageBackData = optimized
                            }
                        }
                    }
                }

                Section("Historia y Anécdotas") {
                    TextField("Dónde se consiguió, precio, anécdota especial...", text: $story, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Añadir Pieza")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveArtifact()
                    }
                    .bold()
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingCountryPicker) {
                CountryPickerView(selectedCountry: $selectedCountry)
            }
            .sheet(isPresented: $showingCoinScanner) {
                CoinScannerView { pngData in
                    imageFrontData = pngData
                }
            }
            .onChange(of: selectedCountry) { _, newCountry in
                currencyCode = newCountry.defaultCurrency
            }
        }
    }

    private func saveArtifact() {
        let yearInt = Int(yearString)
        let matchedTrip = availableTrips.first(where: { $0.id == selectedTripId })

        let artifact = Artifact(
            category: category,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            currencyCode: category.isNumismatic ? currencyCode : nil,
            denomination: category.isNumismatic ? denomination : nil,
            year: yearInt,
            imageFrontData: imageFrontData,
            imageBackData: imageBackData,
            story: story.isEmpty ? nil : story,
            countryCode: selectedCountry.code,
            trip: matchedTrip
        )

        modelContext.insert(artifact)
        if let trip = matchedTrip {
            trip.artifacts.append(artifact)
        }

        HapticManager.shared.notification(.success)
        dismiss()
    }
}
