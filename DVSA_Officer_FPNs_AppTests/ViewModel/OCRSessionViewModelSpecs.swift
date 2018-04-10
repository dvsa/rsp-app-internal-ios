//
//  OCRSessionViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 23/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class OCRSessionViewModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        let viewModel = OCRCameraSessionViewModel(model: NewTokenModel(value: nil))

        describe("OCRSessionViewModel") {
            it("init") {
                expect(viewModel).toNot(beNil())
            }
            it("table row count") {
                expect(viewModel.numberOfRows).to(equal(4))
            }
            it("OCR engine should not be nil") {
                expect(viewModel.ocrEngine).toNot(beNil())
            }
            it("token document should not be nil") {
                expect(viewModel.model).toNot(beNil())
            }
        }

        describe("DetailsRowData enum") {
            it("raw values") {
                expect(DetailsRowData.refNumber.rawValue).to(equal(0))
                expect(DetailsRowData.vehicleReg.rawValue).to(equal(1))
                expect(DetailsRowData.date.rawValue).to(equal(2))
                expect(DetailsRowData.penaltyAmount.rawValue).to(equal(3))
            }
            it("titles") {
                expect(DetailsRowData.refNumber.title).to(equal("Reference: "))
                expect(DetailsRowData.vehicleReg.title).to(equal("Vehicle reg: "))
                expect(DetailsRowData.date.title).to(equal("Date: "))
                expect(DetailsRowData.penaltyAmount.title).to(equal("Amount (£): "))
            }
        }

        context("string to remove") {
            let baseRef = "1231-9-09-IM"
            let baseDate = "05/06/2098"
            let basePenalty = "£89"
            let baseVehRegIM = "cle 12JHS "
            let baseVehRegFPN = "No:  123HSD "

            it("should not change ref, date, penalty") {
                expect(Regex.removeRegexSubStrings(text: baseRef, stringsToRemove: DetailsRowData.refNumber.stringToRemove)).to(equal(baseRef))
                expect(Regex.removeRegexSubStrings(text: baseDate, stringsToRemove: DetailsRowData.date.stringToRemove)).to(equal(baseDate))
            }
            it("should filter and leave registration number only") {
                expect(Regex.removeRegexSubStrings(text: baseVehRegIM,
                                                   stringsToRemove: DetailsRowData.vehicleReg.stringToRemove)).to(equal("12JHS"))
                expect(Regex.removeRegexSubStrings(text: baseVehRegFPN,
                                                   stringsToRemove: DetailsRowData.vehicleReg.stringToRemove)).to(equal("123HSD"))
            }
            it("should filter and remove £ symbol") {
                expect(Regex.removeRegexSubStrings(text: basePenalty, stringsToRemove: DetailsRowData.penaltyAmount.stringToRemove)).to(equal("89"))
            }
        }
        context("token document") {
            it("Cell values for default") {
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 0, section: 0))).to(equal(""))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 1, section: 0))).to(equal(""))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 2, section: 0))).to(equal(""))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 3, section: 0))).to(equal(""))
            }
            it("set values and clear values") {
                viewModel.changeValueAtIndex(indexPath: IndexPath(row: 0, section: 0), value: "ref")
                viewModel.changeValueAtIndex(indexPath: IndexPath(row: 1, section: 0), value: "LD66CHY")
                viewModel.changeValueAtIndex(indexPath: IndexPath(row: 2, section: 0), value: "12/12/1999")
                viewModel.changeValueAtIndex(indexPath: IndexPath(row: 3, section: 0), value: "666")

                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 0, section: 0))).to(equal("ref"))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 1, section: 0))).to(equal("LD66CHY"))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 2, section: 0))).to(equal("12/12/1999"))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 3, section: 0))).to(equal("666"))

                viewModel.clearValueAtIndex(indexPath: IndexPath(row: 0, section: 0))
                viewModel.clearValueAtIndex(indexPath: IndexPath(row: 1, section: 0))
                viewModel.clearValueAtIndex(indexPath: IndexPath(row: 2, section: 0))
                viewModel.clearValueAtIndex(indexPath: IndexPath(row: 3, section: 0))

                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 0, section: 0))).to(equal(""))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 1, section: 0))).to(equal(""))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 2, section: 0))).to(equal(""))
                expect(viewModel.cellValueForSelectedIndex(indexPath: IndexPath(row: 3, section: 0))).to(equal(""))
            }
            it("next empty field index") {
                expect(viewModel.getNextEmptyFieldIndex()).to(equal(IndexPath(row: 0, section: 0)))

                viewModel.changeValueAtIndex(indexPath: IndexPath(row: 0, section: 0), value: "ref")
                expect(viewModel.getNextEmptyFieldIndex()).to(equal(IndexPath(row: 1, section: 0)))

                viewModel.changeValueAtIndex(indexPath: IndexPath(row: 1, section: 0), value: "LD66CHY")
                viewModel.changeValueAtIndex(indexPath: IndexPath(row: 2, section: 0), value: "12/12/1999")
                expect(viewModel.getNextEmptyFieldIndex()).to(equal(IndexPath(row: 3, section: 0)))

                viewModel.clearValueAtIndex(indexPath: IndexPath(row: 1, section: 0))
                expect(viewModel.getNextEmptyFieldIndex()).to(equal(IndexPath(row: 1, section: 0)))

            }
            it("result title") {
                expect(viewModel.resultTitleForSelectedIndex(indexPath: IndexPath(row: 0, section: 0))).to(equal("Reference number"))
                expect(viewModel.resultTitleForSelectedIndex(indexPath: IndexPath(row: 1, section: 0))).to(equal("Vehicle registration"))
                expect(viewModel.resultTitleForSelectedIndex(indexPath: IndexPath(row: 2, section: 0))).to(equal("Date"))
                expect(viewModel.resultTitleForSelectedIndex(indexPath: IndexPath(row: 3, section: 0))).to(equal("Penalty amount (£)"))
            }
            it("regex string") {
                expect(viewModel.regexString(for: IndexPath(row: 0, section: 0))).to(equal("(\\d{12,13}|\\d{1,6}-[0,1]-[1-9]\\d{0,5}-IM)"))
                expect(viewModel.regexString(for: IndexPath(row: 1, section: 0))).to(equal("(cle\\s+[A-Z0-9]{1,10}\\s+|No:\\s+[A-Z0-9]{1,10}\\s+)"))
                expect(viewModel.regexString(for: IndexPath(row: 2, section: 0))).to(equal("\\d{1,2}[\\/\\s]\\d{1,2}[\\/\\s]\\d{4}"))
                expect(viewModel.regexString(for: IndexPath(row: 3, section: 0))).to(equal("£[1-9]\\d{1,3}"))
            }
            it("filtered regex string") {
                expect(DetailsRowData(rawValue: 0)?.filteredRegexString).to(equal(DetailsRowData.refNumber.regexString))
                expect(DetailsRowData(rawValue: 1)?.filteredRegexString).to(equal("[A-Z0-9]{1,10}"))
                expect(DetailsRowData(rawValue: 2)?.filteredRegexString).to(equal(DetailsRowData.date.regexString))
                expect(DetailsRowData(rawValue: 3)?.filteredRegexString).to(equal("[1-9]\\d{1,3}"))
            }
            it("get text from image, test nil") {
                expect(viewModel.getTextFromImage(image: UIImage(), indexPath: IndexPath(row: 0, section: 0))).to(beNil())
            }
        }
    }
}
