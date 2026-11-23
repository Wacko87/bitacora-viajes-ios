import SwiftUI
import PhotosUI

public struct CoinScannerView: View {
    @Environment(\.dismiss) private var dismiss
    public let onCoinCaptured: (Data) -> Void

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var rawImage: UIImage? = nil
    @State private var processedImage: UIImage? = nil
    @State private var isProcessing: Bool = false
    @State private var zoomScale: CGFloat = 1.0

    public init(onCoinCaptured: @escaping (Data) -> Void) {
        self.onCoinCaptured = onCoinCaptured
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Circular guide reticle
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 340)

                    if let processedImage {
                        Image(uiImage: processedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 260, height: 260)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                    } else if let rawImage {
                        Image(uiImage: rawImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 260, height: 260)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.amberAccent, lineWidth: 3)
                            )
                    } else {
                        VStack(spacing: 12) {
                            Circle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .foregroundStyle(Color.amberAccent)
                                .frame(width: 220, height: 220)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "viewfinder")
                                            .font(.system(size: 40))
                                            .foregroundStyle(Color.amberAccent)
                                        Text("Encuadre de la Moneda")
                                            .font(.caption.bold())
                                            .foregroundStyle(.secondary)
                                    }
                                )
                        }
                    }

                    if isProcessing {
                        ProgressView("Aislando contorno y relieve...")
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                Text("Selecciona una fotografía de la moneda. El sistema aislará automáticamente el contorno circular y optimizará el contraste metálico para el visor 3D.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(rawImage == nil ? "Seleccionar Foto de la Moneda" : "Cambiar Fotografía", systemImage: "photo.on.rectangle.angled")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.amberAccent.gradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    if let processedImage, let pngData = processedImage.pngData() {
                        Button {
                            HapticManager.shared.notification(.success)
                            onCoinCaptured(pngData)
                            dismiss()
                        } label: {
                            Label("Usar Moneda Escaneada", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.gradient)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("Escáner Numismático")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                guard let newItem else { return }
                Task {
                    isProcessing = true
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        rawImage = uiImage
                        // Process in background
                        let isolated = CoinScannerService.shared.isolateCircularCoin(from: uiImage) ?? uiImage
                        let enhanced = CoinScannerService.shared.enhanceNumismaticRelief(image: isolated) ?? isolated
                        processedImage = enhanced
                        HapticManager.shared.impact(.medium)
                    }
                    isProcessing = false
                }
            }
        }
    }
}
