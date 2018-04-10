//
//  ImageBufferUtils.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import AVFoundation

class ImageBufferUtils {

    /// This method will process the buffer from AVCapture view and convert it into UIImage
    static func processImageBuffer (sampleBuffer: CMSampleBuffer, completionBlock: (UIImage) -> Void) {

        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)

            let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
            let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
            let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)

            let lumaBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)

            let grayColorSpace = CGColorSpaceCreateDeviceGray()
            let bitMapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

            let context = CGContext(data: lumaBuffer,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesPerRow,
                                    space: grayColorSpace,
                                    bitmapInfo: bitMapInfo.rawValue)

            if let dstImage = context?.makeImage() {
                let image = ImageProcessor.cropImage(cgImage: dstImage)
                let filterSettings = FilterSettings()
                let filteredImage = ImageProcessor.filterImage(sourceImage: image, filterSettings: filterSettings)

                // force main thread call, because the compeletion will affect UI components
                DispatchQueue.main.sync {
                    completionBlock(filteredImage)
                }
            }
            CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        }
    }
}
