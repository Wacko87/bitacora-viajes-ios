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
    @State private var countryCode: String = "ES"
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
            _countryCode = State(initialValue: trip.countryCode)
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

                    HStack {
                        Text("País de Origen")
                        Spacer()
                        TextField("ES", text: $countryCode)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.characters)
                            .frame(width: 80)
                        CountryFlagView(countryCode: countryCode, fontSize: 16)
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
                            TextField("Divisa (EUR, JPY...)", text: $currencyCode)
                                .frame(width: 90)
                        }
                        TextField("Año de Acuñación / Emisión (opcional)", text: $yearString)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Fotografías de la Pieza (Cápsula 3D)") {
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
                                Text("Añadir").foregroundColor(.amberAccent)
                            }
                        }
                    }
                    .onChange(of: frontPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageFrontData = data
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
                                Text("Añadir").foregroundColor(.secondary)
                            }
                        }
                    }
                    .onChange(of: backPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageBackData = data
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
        }
    }

    private func saveArtifact() {
        let yearInt = Int(yearString)
        let matchedTrip = availableTrips.first(where: { $0.id == selectedTripId })

        let artifact = Artifact(
            category: category,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            currencyCode: category.isNumismatic ? currencyCode.uppercased() : nil,
            denomination: category.isNumismatic ? denomination : nil,
            year: yearInt,
            imageFrontData: imageFrontData,
            imageBackData: imageBackData,
            story: story.isEmpty ? nil : story,
            countryCode: countryCode.uppercased().trimmingCharacters(in: .whitespacesAndNewlines),
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
