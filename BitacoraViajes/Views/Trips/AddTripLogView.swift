import SwiftUI
import SwiftData

public struct AddTripLogView: View {
    public let trip: Trip
    public let nextDayNumber: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var dayNumber: Int
    @State private var logDate: Date = Date()
    @State private var title: String = ""
    @State private var notesPartner1: String = ""
    @State private var notesPartner2: String = ""

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

    public init(trip: Trip, nextDayNumber: Int) {
        self.trip = trip
        self.nextDayNumber = nextDayNumber
        _dayNumber = State(initialValue: nextDayNumber)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Jornada") {
                    Stepper("Día del Viaje: \(dayNumber)", value: $dayNumber, in: 1...90)
                    DatePicker("Fecha", selection: $logDate, displayedComponents: .date)
                    TextField("Título del día (ej: Templos de Fushimi Inari)", text: $title)
                }

                Section("Perspectiva de \(partner1.name) (Voz 1)") {
                    TextField("Escribe aquí la crónica o anécdotas de \(partner1.name)...", text: $notesPartner1, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Perspectiva de \(partner2.name) (Voz 2)") {
                    TextField("Escribe aquí la crónica o anécdotas de \(partner2.name)...", text: $notesPartner2, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .navigationTitle("Añadir Jornada a Dos Voces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveLog()
                    }
                    .bold()
                }
            }
        }
    }

    private func saveLog() {
        let log = TripLog(
            dayNumber: dayNumber,
            logDate: logDate,
            title: title.isEmpty ? nil : title,
            notesPartner1: notesPartner1.isEmpty ? nil : notesPartner1,
            notesPartner2: notesPartner2.isEmpty ? nil : notesPartner2,
            trip: trip
        )
        trip.logs.append(log)
        HapticManager.shared.notification(.success)
        dismiss()
    }
}
