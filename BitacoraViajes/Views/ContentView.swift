import SwiftUI
import SwiftData

public struct ContentView: View {
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            TripsListView()
                .tabItem {
                    Label("Viajes", systemImage: "airplane")
                }
                .tag(0)

            NumismaticCabinetView()
                .tabItem {
                    Label("Numismática", systemImage: "circle.circle.fill")
                }
                .tag(1)

            VitrinaView()
                .tabItem {
                    Label("Vitrina", systemImage: "ticket.fill")
                }
                .tag(2)

            PassportView()
                .tabItem {
                    Label("Pasaporte", systemImage: "globe.europe.africa.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.amberAccent)
    }
}
