import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

public final class CoinScannerService: @unchecked Sendable {
    public static let shared = CoinScannerService()

    private let ciContext = CIContext()

    private init() {}

    /// Crops and isolates a circular coin from an input image, making the surrounding area transparent.
    public func isolateCircularCoin(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let minDimension = min(width, height)
        
        // Square crop around center
        let cropRect = CGRect(
            x: (width - minDimension) / 2.0,
            y: (height - minDimension) / 2.0,
            width: minDimension,
            height: minDimension
        )
        
        guard let croppedCG = cgImage.cropping(to: cropRect) else { return nil }
        
        // Create radial mask or circular clipping
        UIGraphicsBeginImageContextWithOptions(CGSize(width: minDimension, height: minDimension), false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage(cgImage: croppedCG)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: minDimension, height: minDimension)
        context.addEllipse(in: bounds)
        context.clip()
        
        UIImage(cgImage: croppedCG).draw(in: bounds)
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return circularImage ?? UIImage(cgImage: croppedCG)
    }

    /// Enhances metal relief and edge sharpness for numismatic preservation
    public func enhanceNumismaticRelief(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // Enhance sharpness and tone
        let unsharp = CIFilter.unsharpMask()
        unsharp.inputImage = ciImage
        unsharp.radius = 2.5
        unsharp.intensity = 0.8
        
        guard let sharpened = unsharp.outputImage else { return image }
        
        let controls = CIFilter.colorControls()
        controls.inputImage = sharpened
        controls.contrast = 1.15
        controls.saturation = 1.05
        
        guard let output = controls.outputImage,
              let cgResult = ciContext.createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgResult)
    }
}
