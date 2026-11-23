import SwiftUI
import SwiftData
import Charts

public struct TripExpensesView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @AppStorage("partner1_name") private var partner1Name: String = "Viajero 1"
    @AppStorage("partner2_name") private var partner2Name: String = "Viajero 2"
    @State private var showingAddExpenseSheet: Bool = false

    public init(trip: Trip) {
        self.trip = trip
    }

    private var totalExpensesEUR: Double {
        trip.expenses.reduce(0.0) { $0 + $1.amountInEUR }
    }

    private var partner1PaidEUR: Double {
        trip.expenses.filter { $0.paidByPartnerIndex == 0 }.reduce(0.0) { $0 + $1.amountInEUR }
    }

    private var partner2PaidEUR: Double {
        trip.expenses.filter { $0.paidByPartnerIndex == 1 }.reduce(0.0) { $0 + $1.amountInEUR }
    }

    private var partner1ShareTotal: Double {
        trip.expenses.reduce(0.0) { $0 + $1.partner1ShareInEUR }
    }

    private var partner2ShareTotal: Double {
        trip.expenses.reduce(0.0) { $0 + $1.partner2ShareInEUR }
    }

    // Positive means Partner 2 owes Partner 1; Negative means Partner 1 owes Partner 2
    private var netBalance: Double {
        partner1PaidEUR - partner1ShareTotal
    }

    private var expensesByCategory: [(category: ExpenseCategory, total: Double)] {
        let grouped = Dictionary(grouping: trip.expenses, by: { $0.category })
        return ExpenseCategory.allCases.compactMap { cat in
            let total = (grouped[cat] ?? []).reduce(0.0) { $0 + $1.amountInEUR }
            return total > 0 ? (category: cat, total: total) : nil
        }.sorted { $0.total > $1.total }
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Summary Card
                VStack(spacing: 12) {
                    Text("Total Gastado en el Viaje")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(totalExpensesEUR, format: .currency(code: "EUR"))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.accentColor)

                    Divider()

                    // Balance Breakdown
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(partner1Name)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text("Aportó:")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(partner1PaidEUR, format: .currency(code: "EUR"))
                                .font(.headline)
                        }

                        Spacer()

                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.tertiary)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(partner2Name)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text("Aportó:")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(partner2PaidEUR, format: .currency(code: "EUR"))
                                .font(.headline)
                        }
                    }
                    .padding(.top, 4)

                    // Settle up banner
                    HStack {
                        Image(systemName: netBalance == 0 ? "checkmark.circle.fill" : "scalemass.fill")
                            .foregroundStyle(netBalance == 0 ? .green : .blue)
                        if netBalance > 0.01 {
                            Text("\(partner2Name) debe abonar \(abs(netBalance), format: .currency(code: "EUR")) a \(partner1Name)")
                                .font(.footnote.weight(.medium))
                        } else if netBalance < -0.01 {
                            Text("\(partner1Name) debe abonar \(abs(netBalance), format: .currency(code: "EUR")) a \(partner2Name)")
                                .font(.footnote.weight(.medium))
                        } else {
                            Text("¡Cuentas perfectamente equilibradas al 50%!")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

                // Category Chart
                if !expensesByCategory.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Distribución por Categoría")
                            .font(.headline)

                        Chart(expensesByCategory, id: \.category) { item in
                            SectorMark(
                                angle: .value("Gasto", item.total),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .cornerRadius(5)
                            .foregroundStyle(by: .value("Categoría", item.category.localizedTitle))
                        }
                        .frame(height: 180)
                        .chartLegend(position: .bottom, spacing: 12)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                }

                // Expenses List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Detalle de Gastos (\(trip.expenses.count))")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingAddExpenseSheet = true
                        } label: {
                            Label("Añadir", systemImage: "plus.circle.fill")
                                .font(.subheadline.bold())
                        }
                    }

                    if trip.expenses.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 40))
                                .foregroundStyle(.tertiary)
                            Text("No hay gastos registrados aún")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Registrar Primer Gasto") {
                                showingAddExpenseSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        ForEach(trip.expenses.sorted(by: { $0.date > $1.date })) { exp in
                            HStack(spacing: 14) {
                                Image(systemName: exp.category.iconName)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.accentColor.gradient)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exp.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text("Pagado por: \(exp.paidByPartnerIndex == 0 ? partner1Name : partner2Name) • \(exp.split.localizedTitle)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(exp.amountInEUR, format: .currency(code: "EUR"))
                                        .font(.subheadline.bold())
                                    if exp.currencyCode.uppercased() != "EUR" {
                                        Text("\(exp.amount, specifier: "%.2f") \(exp.currencyCode)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Gastos del Viaje")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddExpenseSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpenseSheet) {
            AddExpenseSheet(trip: trip)
        }
    }
}

public struct AddExpenseSheet: View {
    @Bindable var trip: Trip
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("partner1_name") private var partner1Name: String = "Viajero 1"
    @AppStorage("partner2_name") private var partner2Name: String = "Viajero 2"

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var currencyCode: String = "EUR"
    @State private var category: ExpenseCategory = .food
    @State private var paidByIndex: Int = 0
    @State private var split: ExpenseSplit = .equal
    @State private var notes: String = ""
    @State private var date: Date = Date()

    public var body: some View {
        NavigationStack {
            Form {
                Section("Concepto e Importe") {
                    TextField("Ej: Cena tradicional, Taxi al aeropuerto", text: $title)

                    HStack {
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title3.bold())

                        Picker("Moneda", selection: $currencyCode) {
                            Text("EUR (€)").tag("EUR")
                            Text("USD ($)").tag("USD")
                            Text("JPY (¥)").tag("JPY")
                            Text("GBP (£)").tag("GBP")
                            Text("CHF").tag("CHF")
                        }
                        .pickerStyle(.menu)
                    }

                    Picker("Categoría", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            Label(cat.localizedTitle, systemImage: cat.iconName).tag(cat)
                        }
                    }
                }

                Section("División de Gastos") {
                    Picker("¿Quién ha pagado?", selection: $paidByIndex) {
                        Text(partner1Name).tag(0)
                        Text(partner2Name).tag(1)
                    }
                    .pickerStyle(.segmented)

                    Picker("Reparto", selection: $split) {
                        ForEach(ExpenseSplit.allCases, id: \.self) { s in
                            Text(s.localizedTitle).tag(s)
                        }
                    }
                }

                Section("Detalles Opcionales") {
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                    TextField("Notas adicionales o enlaces", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Nuevo Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveExpense()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0)
                }
            }
        }
    }

    private func saveExpense() {
        let cleanAmount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let newExpense = TripExpense(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: cleanAmount,
            currencyCode: currencyCode,
            exchangeRateToEUR: 1.0, // Defaults to 1.0; can be adjusted
            category: category,
            paidByPartnerIndex: paidByIndex,
            split: split,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            trip: trip
        )
        trip.expenses.append(newExpense)
        modelContext.insert(newExpense)
        try? modelContext.save()
        dismiss()
    }
}
