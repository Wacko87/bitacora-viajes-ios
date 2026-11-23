import SwiftUI

public struct SettingsView: View {
    @State private var viewModel = ProfileSettingsViewModel()

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
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Persistencia")
                        Spacer()
                        Text("SwiftData (Offline-First)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Gabinete 3D")
                        Spacer()
                        Text("ProMotion 120Hz & Haptics")
                            .foregroundColor(.secondary)
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
