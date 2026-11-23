import SwiftUI
import SwiftData

public struct SettingsView: View {
    @Query private var allTrips: [Trip]
    @State private var viewModel = ProfileSettingsViewModel()
    @State private var isBiometricsEnabled: Bool = BiometricAuthService.shared.isBiometricsEnabled

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Perfiles de la Pareja (Crónica a Dos Voces)") {
                    HStack {
                        Circle()
                            .fill(Color(hex: viewModel.partner1.avatarColorHex) ?? .amberAccent)
                            .frame(width: 24, height: 24)
                        TextField("Nombre Pareja 1", text: $viewModel.partner1.name)
                            .onChange(of: viewModel.partner1.name) { _, _ in
                                viewModel.saveProfiles()
                            }
                    }

                    HStack {
                        Circle()
                            .fill(Color(hex: viewModel.partner2.avatarColorHex) ?? .pink)
                            .frame(width: 24, height: 24)
                        TextField("Nombre Pareja 2", text: $viewModel.partner2.name)
                            .onChange(of: viewModel.partner2.name) { _, _ in
                                viewModel.saveProfiles()
                            }
                    }
                }

                Section("Seguridad y Privacidad") {
                    Toggle(
                        "Bloquear con \(BiometricAuthService.shared.biometricTypeString)",
                        isOn: $isBiometricsEnabled
                    )
                    .onChange(of: isBiometricsEnabled) { _, newValue in
                        BiometricAuthService.shared.isBiometricsEnabled = newValue
                        HapticManager.shared.notification(.success)
                    }
                }

                Section("Copia de Seguridad y Bóveda") {
                    if let backup = VaultBackupService.shared.exportVault(trips: allTrips) {
                        ShareLink(
                            item: backup,
                            preview: SharePreview("Copia de Seguridad Bitácora", image: Image(systemName: "archivebox.fill"))
                        ) {
                            Label("Exportar Bóveda Completa (JSON)", systemImage: "square.and.arrow.up")
                                .foregroundStyle(Color.amberAccent)
                        }
                    }
                }

                Section("Sincronización Opcional con Servidor Propio") {
                    Toggle("Activar Servidor Fastify / Unraid", isOn: $viewModel.serverConfig.isEnabled)
                        .onChange(of: viewModel.serverConfig.isEnabled) { _, _ in
                            Task { await viewModel.saveServerConfig() }
                        }

                    if viewModel.serverConfig.isEnabled {
                        TextField("URL Servidor (ej: https://api.tu-servidor.com)", text: $viewModel.serverConfig.serverURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .onChange(of: viewModel.serverConfig.serverURL) { _, _ in
                                Task { await viewModel.saveServerConfig() }
                            }

                        SecureField("PIN de Acceso / Token", text: $viewModel.serverConfig.apiPin)
                            .onChange(of: viewModel.serverConfig.apiPin) { _, _ in
                                Task { await viewModel.saveServerConfig() }
                            }

                        Button {
                            Task { await viewModel.testServerConnection() }
                        } label: {
                            if viewModel.isTestingConnection {
                                ProgressView()
                            } else {
                                Text("Probar Conexión con Servidor")
                            }
                        }

                        if let message = viewModel.connectionTestMessage {
                            Text(message)
                                .font(.footnote)
                        }
                    }
                }

                Section("Acerca de Bitácora de Viajes") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0 (Nativa iOS)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Persistencia")
                        Spacer()
                        Text("SwiftData (Offline-First)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Gabinete 3D")
                        Spacer()
                        Text("ProMotion 120Hz & Haptics")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .task {
                await viewModel.loadSettings()
            }
        }
    }
}
