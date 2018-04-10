//
//  ImageProcessor.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import GPUImage

public struct FilterSettings {

    static let defaultAdaptiveBlurRadius: CGFloat = 15.0
    static let defaultLuminanceThreshold: CGFloat = 0.5
    static let defaultGaussianBlurRadius: CGFloat = 3.0
    static let defaultSharpenSharpness: CGFloat = 4.0

    public var adaptiveBlurRadius = FilterSettings.defaultAdaptiveBlurRadius
    public var luminanceThreshold = FilterSettings.defaultLuminanceThreshold
    public var gaussianBlurRadius = FilterSettings.defaultGaussianBlurRadius
    public var sharpenSharpness = FilterSettings.defaultSharpenSharpness
}

class ImageProcessor: NSObject {

    static let defaultScale: CGFloat = 1.0

    //** Open methods for external usage */

    // crop cgimage to view finder size and draw cgImage from it
    static func cropImage (cgImage: CGImage) -> UIImage {
        let rect: CGRect = CGRect(x: ImageProcessor.next8(input: CGFloat(Double(cgImage.width) * 0.45)),
                                  y: ImageProcessor.next8(input: CGFloat(Double(cgImage.height) * 0.1)),
                                  width: ImageProcessor.next8(input: CGFloat(Double(cgImage.width) * 0.1)),
                                  height: ImageProcessor.next8(input: CGFloat(Double(cgImage.height) * 0.8)))

        let imageRef = cgImage.cropping(to: rect)
        return UIImage(cgImage: imageRef!, scale: self.defaultScale, orientation: .right)
    }

    static func filterImage (sourceImage: UIImage, filterSettings: FilterSettings) -> UIImage {
        var image: UIImage

        image = ImageProcessor.preprocesImageAdaptive(sourceImage: sourceImage, blurRadius: filterSettings.adaptiveBlurRadius)
        image = ImageProcessor.preprocessImageRemoveNoise(sourceImage: image, blurRadius: filterSettings.gaussianBlurRadius)
        image = ImageProcessor.preprocessImageSharpen(sourceImage: image, sharpness: filterSettings.sharpenSharpness)

        return image
    }

    static func preprocesImageAdaptive (sourceImage: UIImage, blurRadius: CGFloat) -> UIImage {
        let inputImage = sourceImage
        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
        stillImageFilter.blurRadiusInPixels = blurRadius

        return stillImageFilter.image(byFilteringImage: inputImage)
    }

    static func preprocessImageLuminance (sourceImage: UIImage, threshold: CGFloat) -> UIImage {
        let inputImage = sourceImage
        let stillImageFilter = GPUImageLuminanceThresholdFilter()
        stillImageFilter.threshold = threshold

        return stillImageFilter.image(byFilteringImage: inputImage)
    }

    static func preprocessImageRemoveNoise (sourceImage: UIImage, blurRadius: CGFloat) -> UIImage {
        let inputImage = sourceImage
        let stillImageFilter = GPUImageGaussianBlurFilter()
        stillImageFilter.blurRadiusInPixels = blurRadius

        return stillImageFilter.image(byFilteringImage: inputImage)
    }

    static func preprocessImageSharpen (sourceImage: UIImage, sharpness: CGFloat) -> UIImage {
        let inputImage = sourceImage
        let stillImageFilter = GPUImageSharpenFilter()
        stillImageFilter.sharpness = sharpness

        return stillImageFilter.image(byFilteringImage: inputImage)
    }

    // set size to the next multiple of 8 to fit bytes processing
    static func next8 (input: CGFloat) -> CGFloat {
        let intValue = Int(input)
        let bits = intValue & 7
        if bits == 0 {
            return CGFloat(input)
        }
        return CGFloat(intValue) + CGFloat(8 - bits)
    }
}
