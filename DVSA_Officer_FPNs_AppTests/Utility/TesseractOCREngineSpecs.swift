//
//  TesseractOCREngineSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import TesseractOCR
@testable import DVSA_Officer_FPNs_App

class TesseractOCREngineSpecs: QuickSpec {
    override func spec() {

        let testEngineSettings = OCREngineSettings()
        let testEngine = TesseractOCREngine()

        describe("OCREngineSettings") {
            context("Init") {
                it("should not be nil") {
                    expect(testEngineSettings).toNot(beNil())
                }
            }
            context("Default values") {
                it("language is english only") {
                    expect(testEngineSettings.languageSetting).to(equal("eng"))
                }
                it("recognition time") {
                    expect(testEngineSettings.recognitionTime).to(equal(0.3))
                }
                it("fixed orientation only") {
                    expect(testEngineSettings.fixOrientation).to(beTrue())
                }
                it("black and white only") {
                    expect(testEngineSettings.blackAndWhiteImage).to(beFalse())
                }
                it("white list") {
                    expect(testEngineSettings.whiteList).to(beNil())
                }
                it("detection rect") {
                    expect(testEngineSettings.rect).to(beNil())
                }
            }
        }

        describe("TesseractOCREngine") {
            context("Init") {
                it("should not be nil") {
                    expect(testEngine).toNot(beNil())
                }
                it("tesseract object should not be nil") {
                    expect(testEngine.tesseract).toNot(beNil())
                }
                it("engine mode is tess only") {
                    expect(testEngine.engineMode).to(equal(G8OCREngineMode.tesseractOnly))
                }
            }
            context("Preprocess image") {
                let testImage = UIImage()
                let processedImage = testEngine.preprocessedImage(for: testEngine.tesseract, sourceImage: testImage)
                it("should not change image") {
                    expect(testImage).to(equal(processedImage))
                }
            }
        }
    }
}
