import SwiftUI
import SwiftData
import PhotosUI

public struct AddEditTripView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var selectedCountry: CountryInfo = CountryCatalog.find(code: "JP")
    @State private var showingCountryPicker: Bool = false
    @State private var city: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400 * 4)
    @State private var status: TripStatus = .active
    @State private var summary: String = ""
    @State private var totalCostString: String = ""
    @State private var costCurrency: String = "JPY"
    @State private var inclusions: String = ""
    @State private var costNotes: String = ""

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var coverImageData: Data? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Destino") {
                    TextField("Título del Viaje (ej: Escapada a Kioto)", text: $title)

                    Button {
                        showingCountryPicker = true
                    } label: {
                        HStack {
                            Text("País de Destino")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(selectedCountry.flag) \(selectedCountry.name)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
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
                            .foregroundStyle(Color.amberAccent)
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let rawData = try? await newItem?.loadTransferable(type: Data.self) {
                                let optimized = ImageOptimizerService.shared.downsample(imageData: rawData, maxDimension: 1920) ?? rawData
                                coverImageData = optimized
                            }
                        }
                    }
                }

                Section("Presupuesto e Inclusiones") {
                    HStack {
                        TextField("Coste Total", text: $totalCostString)
                            .keyboardType(.decimalPad)
                        Text(costCurrency)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.amberAccent)
                            .frame(width: 60)
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
            .sheet(isPresented: $showingCountryPicker) {
                CountryPickerView(selectedCountry: $selectedCountry)
            }
            .onChange(of: selectedCountry) { _, newCountry in
                costCurrency = newCountry.defaultCurrency
            }
        }
    }

    private func saveTrip() {
        let cost = Double(totalCostString.replacingOccurrences(of: ",", with: "."))
        let trip = Trip(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            countryCode: selectedCountry.code,
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
