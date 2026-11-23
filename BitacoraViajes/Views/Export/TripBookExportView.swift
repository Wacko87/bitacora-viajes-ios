import SwiftUI
import PDFKit

public struct TripBookExportView: View {
    public let trip: Trip
    public let partner1: PartnerProfile
    public let partner2: PartnerProfile

    @Environment(\.dismiss) private var dismiss
    @State private var pdfData: Data? = nil

    public init(trip: Trip, partner1: PartnerProfile, partner2: PartnerProfile) {
        self.trip = trip
        self.partner1 = partner1
        self.partner2 = partner2
    }

    public var body: some View {
        NavigationStack {
            VStack {
                if let data = pdfData, let document = PDFDocument(data: data) {
                    PDFKitRepresentedView(document: document)
                        .edgesIgnoringSafeArea(.bottom)
                } else {
                    ProgressView("Maquetando Libro Editorial de Viaje...")
                        .padding()
                }
            }
            .navigationTitle("Libro de Viaje Editorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }

                if let data = pdfData {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(
                            item: PDFFileItem(data: data, title: "Libro_\(trip.title).pdf"),
                            preview: SharePreview("Libro de Viaje: \(trip.title)", image: Image(systemName: "book.pages.fill"))
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.amberAccent)
                        }
                    }
                }
            }
            .onAppear {
                generatePDF()
            }
        }
    }

    private func generatePDF() {
        DispatchQueue.main.async {
            self.pdfData = PDFExportService.shared.generateTripBook(
                trip: trip,
                partner1: partner1,
                partner2: partner2
            )
        }
    }
}

public struct PDFFileItem: Transferable {
    public let data: Data
    public let title: String

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { item in
            item.data
        }
    }
}

public struct PDFKitRepresentedView: UIViewRepresentable {
    public let document: PDFDocument

    public func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    public func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}
