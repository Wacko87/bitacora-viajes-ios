import SwiftUI
import SwiftData
import PhotosUI

public struct AddEditTripView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var countryCode: String = "ES"
    @State private var city: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400 * 4)
    @State private var status: TripStatus = .active
    @State private var summary: String = ""
    @State private var totalCostString: String = ""
    @State private var costCurrency: String = "EUR"
    @State private var inclusions: String = ""
    @State private var costNotes: String = ""

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var coverImageData: Data? = nil
    @State private var isFetchingWeather: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Destino") {
                    TextField("Título del Viaje (ej: Escapada a Kioto)", text: $title)
                    HStack {
                        Text("Código de País (ISO)")
                        Spacer()
                        TextField("ES, JP, US...", text: $countryCode)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.characters)
                            .frame(width: 80)
                        CountryFlagView(countryCode: countryCode, fontSize: 18)
                    }
                    TextField("Ciudad principal (ej: Kioto, Tokio)", text: $city)
                }

                Section("Fechas y Estado") {
                    DatePicker("Inicio", selection: $startDate, displayedComponents: .date)
                    DatePicker("Fin", selection: $endDate, displayedComponents: .date)
                    Picker("Estado", selection: $status) {
                        ForEach(TripStatus.allCases, id: \.self) { s in
                            Text(s.localizedTitle).tag(s)
                        }
                    }
                }

                Section("Foto de Portada") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        if let data = coverImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Seleccionar foto de portada")
                            }
                            .foregroundColor(.amberAccent)
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                coverImageData = data
                            }
                        }
                    }
                }

                Section("Presupuesto e Inclusiones") {
                    HStack {
                        TextField("Coste Total", text: $totalCostString)
                            .keyboardType(.decimalPad)
                        Picker("Divisa", selection: $costCurrency) {
                            Text("EUR (€)").tag("EUR")
                            Text("USD ($)").tag("USD")
                            Text("JPY (¥)").tag("JPY")
                            Text("GBP (£)").tag("GBP")
                        }
                    }
                    TextField("Inclusiones (Vuelos, Hotel, Seguro...)", text: $inclusions)
                    TextField("Notas adicionales de gastos", text: $costNotes)
                }

                Section("Resumen Editorial") {
                    TextField("Resumen o prólogo de la expedición...", text: $summary, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nueva Expedición")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTrip()
                    }
                    .bold()
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveTrip() {
        let cost = Double(totalCostString.replacingOccurrences(of: ",", with: "."))
        let trip = Trip(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            countryCode: countryCode.uppercased().trimmingCharacters(in: .whitespacesAndNewlines),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : city,
            startDate: startDate,
            endDate: endDate,
            coverImageData: coverImageData,
            status: status,
            summary: summary.isEmpty ? nil : summary,
            totalCost: cost,
            costCurrency: costCurrency,
            inclusions: inclusions.isEmpty ? nil : inclusions,
            costNotes: costNotes.isEmpty ? nil : costNotes
        )

        modelContext.insert(trip)
        HapticManager.shared.notification(.success)

        // Asynchronously fetch initial weather
        Task {
            let weather = await WeatherService.shared.fetchWeather(
                forCity: trip.city,
                countryCode: trip.countryCode,
                startDate: trip.startDate,
                endDate: trip.endDate
            )
            trip.tempMin = weather.tempMin
            trip.tempMax = weather.tempMax
        }

        dismiss()
    }
}
