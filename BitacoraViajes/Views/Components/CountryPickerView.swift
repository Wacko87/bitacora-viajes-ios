import SwiftUI

public struct CountryPickerView: View {
    @Binding public var selectedCountry: CountryInfo
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""

    public init(selectedCountry: Binding<CountryInfo>) {
        self._selectedCountry = selectedCountry
    }

    public var filteredCountries: [CountryInfo] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return CountryCatalog.catalog
        }
        let term = searchText.lowercased()
        return CountryCatalog.catalog.filter {
            $0.name.lowercased().contains(term) || $0.code.lowercased().contains(term)
        }
    }

    public var body: some View {
        NavigationStack {
            List(filteredCountries) { country in
                Button {
                    HapticManager.shared.impact(.light)
                    selectedCountry = country
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Text(country.flag)
                            .font(.system(size: 28))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text("Moneda: \(country.defaultCurrency) (\(country.currencySymbol))")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if selectedCountry.code == country.code {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.amberAccent)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Seleccionar País")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar país...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
