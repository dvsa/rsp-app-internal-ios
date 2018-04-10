//
//  TesseractOCREngine.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import TesseractOCR

struct OCREngineSettings {
    // Language to detect, ENG by default
    // Current Tesseract 3 for iOS only support one language
    var languageSetting: String = "eng"

    // max time given for tesseract to detect text, default value is 0.3
    // give more time to increase accuracy
    var recognitionTime: Double = 0.3

    // If tesseract is expecting a fixed orientation image imput
    var fixOrientation: Bool = true

    // Should use black & white image
    var blackAndWhiteImage: Bool = false

    // White list characters
    var whiteList: String?

    // Tesseract detection rect
    var rect: CGRect?

}

class TesseractOCREngine: NSObject, G8TesseractDelegate {

    var tesseract: G8Tesseract?
    var engineSettings: OCREngineSettings = OCREngineSettings()

    // Engine mode, tesseract is fastest, least accurate
    // cube only is slowest, most accurate, combined is in between
    var engineMode = G8OCREngineMode.tesseractOnly {
        didSet {
            tesseract = G8Tesseract(language: engineSettings.languageSetting, engineMode: engineMode)
            tesseract?.delegate = self
        }
    }

    override init() {
        tesseract = G8Tesseract(language: engineSettings.languageSetting, engineMode: engineMode)
        super.init()
        tesseract?.delegate = self
    }

    // remove this method if not using preprocessed image
    // Tesseract will use Otsu filter by default.
    func preprocessedImage(for tesseract: G8Tesseract!, sourceImage: UIImage!) -> UIImage! {
        return sourceImage
    }

    func getTextFromImage (image: UIImage) -> String {

        if let unwrappedTesseract = tesseract {
            // Update image with image settings
            var processedImage = image
            if engineSettings.fixOrientation {
                processedImage = processedImage.fixOrientation()
            }
            if engineSettings.blackAndWhiteImage {
                processedImage = processedImage.g8_blackAndWhite()
            }
            if engineSettings.whiteList != nil {
                unwrappedTesseract.charWhitelist = engineSettings.whiteList!
            }
            if engineSettings.rect != nil {
                unwrappedTesseract.rect = engineSettings.rect!
            }

            // recognize image
            unwrappedTesseract.image = processedImage
            unwrappedTesseract.maximumRecognitionTime = engineSettings.recognitionTime
            unwrappedTesseract.recognize()

            return unwrappedTesseract.recognizedText ?? ""
        }
        return ""
    }
}
