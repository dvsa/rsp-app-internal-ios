//
//  ImageProcessorSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class ImageProcessorSpecs: QuickSpec {
    override func spec() {

        let defaultSettins = FilterSettings()
        var filterSettings = FilterSettings()
        let testImage = UIImage(named: "ms-icon") ?? UIImage()

        describe("FilterSettings") {
            context("Init") {
                it("should not be nil") {
                    expect(filterSettings).toNot(beNil())
                }
            }
            context("Filter values") {
                it("adaptive blur default") {
                    expect(defaultSettins.adaptiveBlurRadius).to(equal(FilterSettings.defaultAdaptiveBlurRadius))
                }
                it("gaussian blur default") {
                    expect(defaultSettins.gaussianBlurRadius).to(equal(FilterSettings.defaultGaussianBlurRadius))
                }
                it("luminance threshold default") {
                    expect(defaultSettins.luminanceThreshold).to(equal(FilterSettings.defaultLuminanceThreshold))
                }
                it("sharpen default") {
                    expect(defaultSettins.sharpenSharpness).to(equal(FilterSettings.defaultSharpenSharpness))
                }
            }
            context("Change values") {

                filterSettings.adaptiveBlurRadius = 0.1
                filterSettings.gaussianBlurRadius = 0.2
                filterSettings.luminanceThreshold = 0.3
                filterSettings.sharpenSharpness = 0.4

                it("adaptive blur default") {
                    expect(filterSettings.adaptiveBlurRadius).to(equal(0.1))
                }
                it("gaussian blur default") {
                    expect(filterSettings.gaussianBlurRadius).to(equal(0.2))
                }
                it("luminance threshold default") {
                    expect(filterSettings.luminanceThreshold).to(equal(0.3))
                }
                it("sharpen default") {
                    expect(filterSettings.sharpenSharpness).to(equal(0.4))
                }
            }
        }

        describe("ImageProcessor") {
            it("test image should not be nil") {
                expect(testImage).toNot(beNil())
            }
            it("default scale") {
                expect(ImageProcessor.defaultScale).to(equal(1.0))
            }
            context("crop image") {
                it("should return UIImage type") {
                    if let image = UIImage(named: "ms-icon")?.cgImage {
                        expect(ImageProcessor.cropImage(cgImage: image) is UIImage).to(beTrue())
                    }
                }
            }
            context("Adaptive filter") {
                let filteredImage = ImageProcessor.preprocesImageAdaptive(sourceImage: testImage,
                                                                          blurRadius: filterSettings.adaptiveBlurRadius)
                it("should not be nil") {
                    expect(filteredImage).toNot(beNil())
                }
            }
            context("Luminance filter") {
                let filteredImage = ImageProcessor.preprocessImageLuminance(sourceImage: testImage,
                                                                            threshold: filterSettings.luminanceThreshold)
                it("should not be nil") {
                    expect(filteredImage).toNot(beNil())
                }
            }
            context("Gaussian filter") {
                let filteredImage = ImageProcessor.preprocessImageRemoveNoise(sourceImage: testImage,
                                                                              blurRadius: filterSettings.gaussianBlurRadius)
                it("should not be nil") {
                    expect(filteredImage).toNot(beNil())
                }
            }
            context("Sharpen filter") {
                let filteredImage = ImageProcessor.preprocessImageSharpen(sourceImage: testImage,
                                                                          sharpness: filterSettings.sharpenSharpness)
                it("should not be nil") {
                    expect(filteredImage).toNot(beNil())
                }
            }
            context("Multiple filter") {
                let filteredImage = ImageProcessor.filterImage(sourceImage: testImage, filterSettings: filterSettings)
                it("should not be nil") {
                    expect(filteredImage).toNot(beNil())
                }
            }
            context("next 8 function") {
                it("equal to 0") {
                    expect(ImageProcessor.next8(input: 0.0)).to(equal(0.0))
                }
                it("1 to 7") {
                    expect(ImageProcessor.next8(input: 1.0)).to(equal(8.0))
                }
                it("5 to 7") {
                    expect(ImageProcessor.next8(input: 5.0)).to(equal(8.0))
                }
                it("9 to 15") {
                    expect(ImageProcessor.next8(input: 9.0)).to(equal(16.0))
                }
                let random = Int(arc4random_uniform(1000))
                let expectedResult = (random % 8) == 0 ? random : (random/8 + 1) * 8
                it("test random") {
                    expect(ImageProcessor.next8(input: CGFloat(random))).to(equal(CGFloat(expectedResult)))
                }
            }
        }
    }
}
