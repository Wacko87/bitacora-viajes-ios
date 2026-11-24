import UIKit
import ImageIO

public final class ImageOptimizerService: Sendable {
    public static let shared = ImageOptimizerService()
    public static let maxRawByteSize: Int = 30 * 1024 * 1024 // 30 MB max payload protection

    private init() {}

    /// Downsamples image data directly at decode time using ImageIO, bypassing massive bitmap RAM allocation.
    /// - Parameters:
    ///   - data: Raw image data from PhotosPicker or Camera.
    ///   - maxDimension: Maximum pixel dimension (e.g. 1920 for cover, 600 for coins, 300 for thumbnails).
    ///   - compressionQuality: JPEG compression level (0.80 - 0.88 recommended for high fidelity).
    /// - Returns: Optimized, downsampled Data.
    public func downsample(imageData: Data, maxDimension: CGFloat = 1920, compressionQuality: CGFloat = 0.85) -> Data? {
        // Punto 16: Límite estricto de tamaño de archivo (máx 30 MB)
        guard imageData.count <= Self.maxRawByteSize else {
            return nil
        }

        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions as CFDictionary) else {
            return nil
        }

        let uiImage = UIImage(cgImage: downsampledImage)
        return uiImage.jpegData(compressionQuality: compressionQuality)
    }

    /// Optimized downsampling specifically for circular coins preserving PNG alpha transparency
    public func downsampleCoinPNG(imageData: Data, maxDimension: CGFloat = 600) -> Data? {
        // Punto 16: Límite estricto de tamaño de archivo (máx 30 MB)
        guard imageData.count <= Self.maxRawByteSize else {
            return nil
        }

        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return imageData
        }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions as CFDictionary) else {
            return imageData
        }

        return UIImage(cgImage: downsampledImage).pngData()
    }
}
