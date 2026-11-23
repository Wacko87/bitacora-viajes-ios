import Foundation
import PDFKit
import UIKit

@MainActor
public final class PDFExportService {
    public static let shared = PDFExportService()

    private init() {}

    public func generateTripBook(
        trip: Trip,
        partner1: PartnerProfile,
        partner2: PartnerProfile
    ) -> Data {
        let pageWidth: CGFloat = 595.2 // A4 standard width in points
        let pageHeight: CGFloat = 841.8 // A4 standard height in points
        let margin: CGFloat = 40.0
        let contentWidth = pageWidth - (margin * 2)

        let pdfMetaData = [
            kCGPDFContextCreator: "Bitácora de Viajes",
            kCGPDFContextAuthor: "\(partner1.name) & \(partner2.name)",
            kCGPDFContextTitle: trip.title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            // PAGE 1: COVER
            context.beginPage()
            drawCoverPage(trip: trip, partner1: partner1, partner2: partner2, in: pageRect, margin: margin, width: contentWidth)

            // PAGE 2+: DAILY CHRONICLES
            let sortedLogs = trip.logs.sorted { ($0.dayNumber ?? 0) < ($1.dayNumber ?? 0) }
            if !sortedLogs.isEmpty {
                context.beginPage()
                drawChroniclesPage(logs: sortedLogs, trip: trip, partner1: partner1, partner2: partner2, in: pageRect, margin: margin, width: contentWidth)
            }

            // PAGE 3: NUMISMATIC & VITRINA GALLERY
            if !trip.artifacts.isEmpty {
                context.beginPage()
                drawArtifactsPage(artifacts: trip.artifacts, trip: trip, in: pageRect, margin: margin, width: contentWidth)
            }
        }

        return data
    }

    private func drawCoverPage(
        trip: Trip,
        partner1: PartnerProfile,
        partner2: PartnerProfile,
        in pageRect: CGRect,
        margin: CGFloat,
        width: CGFloat
    ) {
        var currentY: CGFloat = margin + 40

        // Subtitle / Eyebrow
        let eyebrow = "CUADERNO DE EXPEDICIÓN • CRÓNICA A DOS VOCES"
        let eyebrowAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: UIColor.systemAmber
        ]
        eyebrow.draw(at: CGPoint(x: margin, y: currentY), withAttributes: eyebrowAttrs)
        currentY += 24

        // Main Title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 32, weight: .black),
            .foregroundColor: UIColor.label
        ]
        let titleRect = CGRect(x: margin, y: currentY, width: width, height: 80)
        trip.title.draw(in: titleRect, withAttributes: titleAttrs)
        currentY += 80

        // Location & Dates
        let location = [trip.city, trip.countryCode].compactMap { $0 }.joined(separator: ", ")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "es_ES")
        let dateRange = "\(dateFormatter.string(from: trip.startDate)) — \(dateFormatter.string(from: trip.endDate))"
        let locString = "\(location)  •  \(dateRange)  (\(trip.durationInDays) días)"

        let locAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        locString.draw(at: CGPoint(x: margin, y: currentY), withAttributes: locAttrs)
        currentY += 30

        // Cover Image (if available)
        if let coverData = trip.coverImageData, let coverImage = UIImage(data: coverData) {
            let imageHeight: CGFloat = 280
            let imageRect = CGRect(x: margin, y: currentY, width: width, height: imageHeight)

            UIBezierPath(roundedRect: imageRect, cornerRadius: 16).addClip()
            coverImage.draw(in: imageRect)
            currentY += imageHeight + 30
        } else {
            currentY += 20
        }

        // Summary box
        if let summary = trip.summary, !summary.isEmpty {
            let summaryBoxRect = CGRect(x: margin, y: currentY, width: width, height: 80)
            UIColor.secondarySystemBackground.setFill()
            UIBezierPath(roundedRect: summaryBoxRect, cornerRadius: 12).fill()

            let summaryAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 13),
                .foregroundColor: UIColor.label
            ]
            let textInsetsRect = summaryBoxRect.insetBy(dx: 16, dy: 16)
            summary.draw(in: textInsetsRect, withAttributes: summaryAttrs)
            currentY += 100
        }

        // Metrics Banner: Clima & Presupuesto
        let metricsY = pageRect.height - margin - 80
        let metricsRect = CGRect(x: margin, y: metricsY, width: width, height: 60)
        UIColor.systemGray6.setFill()
        UIBezierPath(roundedRect: metricsRect, cornerRadius: 10).fill()

        var tempStr = "Clima: N/D"
        if let min = trip.tempMin, let max = trip.tempMax {
            tempStr = "Clima histórico: \(min)°C a \(max)°C"
        }
        var costStr = "Coste no registrado"
        if let cost = trip.totalCost {
            costStr = String(format: "Inversión total: %.2f %@", cost, trip.costCurrency ?? "EUR")
        }

        let metricsText = "\(tempStr)   |   \(costStr)\nAutores: \(partner1.name) & \(partner2.name)"
        let metricAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        metricsText.draw(in: metricsRect.insetBy(dx: 12, dy: 14), withAttributes: metricAttrs)
    }

    private func drawChroniclesPage(
        logs: [TripLog],
        trip: Trip,
        partner1: PartnerProfile,
        partner2: PartnerProfile,
        in pageRect: CGRect,
        margin: CGFloat,
        width: CGFloat
    ) {
        var currentY: CGFloat = margin + 20

        // Page Header
        let headerText = "CRÓNICA DIARIA A DOS VOCES"
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        headerText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttrs)
        currentY += 36

        let columnWidth = (width - 16) / 2
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "es_ES")

        for log in logs {
            guard currentY + 140 < pageRect.height - margin else { break }

            let dayTitle = "Día \(log.dayNumber ?? 1): \(log.title ?? dateFormatter.string(from: log.logDate))"
            let dayAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.systemAmber
            ]
            dayTitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: dayAttrs)
            currentY += 24

            // Column 1 (Partner 1)
            let col1Rect = CGRect(x: margin, y: currentY, width: columnWidth, height: 90)
            UIColor.systemGray6.setFill()
            UIBezierPath(roundedRect: col1Rect, cornerRadius: 8).fill()

            let p1Title = "Perspectiva de \(partner1.name)"
            let p1TitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor.secondaryLabel
            ]
            p1Title.draw(at: CGPoint(x: margin + 8, y: currentY + 6), withAttributes: p1TitleAttrs)

            let p1Notes = log.notesPartner1 ?? "Sin notas registradas aún."
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.label
            ]
            p1Notes.draw(in: CGRect(x: margin + 8, y: currentY + 22, width: columnWidth - 16, height: 60), withAttributes: bodyAttrs)

            // Column 2 (Partner 2)
            let col2Rect = CGRect(x: margin + columnWidth + 16, y: currentY, width: columnWidth, height: 90)
            UIColor.systemGray6.setFill()
            UIBezierPath(roundedRect: col2Rect, cornerRadius: 8).fill()

            let p2Title = "Perspectiva de \(partner2.name)"
            p2Title.draw(at: CGPoint(x: margin + columnWidth + 24, y: currentY + 6), withAttributes: p1TitleAttrs)

            let p2Notes = log.notesPartner2 ?? "Sin notas registradas aún."
            p2Notes.draw(in: CGRect(x: margin + columnWidth + 24, y: currentY + 22, width: columnWidth - 16, height: 60), withAttributes: bodyAttrs)

            currentY += 106
        }
    }

    private func drawArtifactsPage(
        artifacts: [Artifact],
        trip: Trip,
        in pageRect: CGRect,
        margin: CGFloat,
        width: CGFloat
    ) {
        var currentY: CGFloat = margin + 20

        let headerText = "GABINETE NUMISMÁTICO Y VITRINA DE RECUERDOS"
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        headerText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttrs)
        currentY += 36

        let itemWidth: CGFloat = (width - 16) / 2
        let itemHeight: CGFloat = 80
        var col: CGFloat = 0

        for artifact in artifacts {
            guard currentY + itemHeight < pageRect.height - margin else { break }

            let itemX = margin + col * (itemWidth + 16)
            let boxRect = CGRect(x: itemX, y: currentY, width: itemWidth, height: itemHeight)

            UIColor.systemGray6.setFill()
            UIBezierPath(roundedRect: boxRect, cornerRadius: 8).fill()

            // Thumbnail
            var textOffset: CGFloat = 10
            if let imgData = artifact.imageFrontData, let image = UIImage(data: imgData) {
                let imgRect = CGRect(x: itemX + 8, y: currentY + 10, width: 60, height: 60)
                UIBezierPath(roundedRect: imgRect, cornerRadius: 6).addClip()
                image.draw(in: imgRect)
                textOffset = 76
            }

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            artifact.title.draw(in: CGRect(x: itemX + textOffset, y: currentY + 10, width: itemWidth - textOffset - 8, height: 20), withAttributes: titleAttrs)

            let subText = "\(artifact.category.localizedName) • \(artifact.denomination ?? "") \(artifact.currencyCode ?? "")"
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ]
            subText.draw(at: CGPoint(x: itemX + textOffset, y: currentY + 30), withAttributes: subAttrs)

            if col == 0 {
                col = 1
            } else {
                col = 0
                currentY += itemHeight + 12
            }
        }
    }
}

private extension UIColor {
    static var systemAmber: UIColor {
        UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1.0)
    }
}
