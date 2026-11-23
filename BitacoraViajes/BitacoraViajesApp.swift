import SwiftUI
import SwiftData

@main
struct BitacoraViajesApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Trip.self,
                TripLog.self,
                Artifact.self,
                TripPhoto.self
            ])
            self.container = try ModelContainer(for: schema)
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }

    @MainActor
    public static func seedInitialDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Trip>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let sampleTrip = Trip(
            title: "Expedición a Kioto & Tokio",
            countryCode: "JP",
            city: "Kioto",
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            status: .completed,
            summary: "Nuestra primera gran travesía juntos por el país del sol naciente. Templos milenarios, cerezos y gastronomía inolvidable.",
            totalCost: 3200.0,
            costCurrency: "EUR",
            inclusions: "Vuelos, JR Pass, Ryokan en Gion y hoteles",
            costNotes: "Inversión compartida al 50%",
            tempMin: 12.0,
            tempMax: 22.0
        )
        context.insert(sampleTrip)

        let logDay1 = TripLog(
            dayNumber: 1,
            logDate: sampleTrip.startDate,
            title: "Llegada y Santuario Fushimi Inari",
            notesPartner1: "Caminamos entre miles de toriis rojos al atardecer. La atmósfera de silencio y misticismo en la montaña nos dejó sin palabras.",
            notesPartner2: "El paseo bajo los toriis fue mágico. Paramos a tomar té matcha recién preparado en una pequeña casa tradicional a mitad del sendero.",
            trip: sampleTrip
        )
        sampleTrip.logs.append(logDay1)

        let coin1 = Artifact(
            category: .coin,
            title: "Moneda de 5 Yenes (Go-en de la Suerte)",
            currencyCode: "JPY",
            denomination: "5",
            year: 2024,
            story: "Conseguida en la ofrenda del templo Fushimi Inari. La palabra 'go-en' significa buen destino y lazos afectivos.",
            countryCode: "JP",
            trip: sampleTrip
        )
        sampleTrip.artifacts.append(coin1)

        let ticket1 = Artifact(
            category: .ticket,
            title: "Pase Tren Bala Shinkansen Tokaido",
            story: "Billete del trayecto a 300 km/h contemplando la silueta nevada del Monte Fuji desde la ventana.",
            countryCode: "JP",
            trip: sampleTrip
        )
        sampleTrip.artifacts.append(ticket1)

        try? context.save()
    }
}
