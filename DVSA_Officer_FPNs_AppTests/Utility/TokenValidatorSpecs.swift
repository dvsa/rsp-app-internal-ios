//
//  TokenValidatorSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 30/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Nimble
import Quick

@testable import DVSA_Officer_FPNs_App

class TokenValidatorSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("TokenValidator") {
            context("reference number") {
                it("12 or 13 digit length") {
                    let string12 = "123456789012"
                    let string13 = "123456789013"
                    let stringShort = "1234"
                    let stringLong = "12345678929342342342"
                    let stringWithChar = "1234567890abc"
                    let beginWithZero = "0123456789012"
                    expect(TokenValidator.validateRefNumber(string: string12)).to(beTrue())
                    expect(TokenValidator.validateRefNumber(string: string13)).to(beTrue())
                    expect(TokenValidator.validateRefNumber(string: stringShort)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: stringLong)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: stringWithChar)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: beginWithZero)).toNot(beTrue())
                }
                it("immobilisation notice format") {
                    let correct = "1234-1-123-IM"
                    let noIM = "1234-1-123"
                    let wrongFormat = "123-1-IM"
                    let beginWithZero1 = "0123-1-123-IM"
                    let beginWithZero2 = "123-1-0123-IM"
                    expect(TokenValidator.validateRefNumber(string: correct)).to(beTrue())
                    expect(TokenValidator.validateRefNumber(string: noIM)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: wrongFormat)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: beginWithZero1)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: beginWithZero2)).toNot(beTrue())

                    let firstPartWrong = "0-1-123-IM"
                    let secondPartWrong = "11-3-123-IM"
                    let thirdPartWrong = "1234-0-12345678-IM"
                    expect(TokenValidator.validateRefNumber(string: firstPartWrong)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: secondPartWrong)).toNot(beTrue())
                    expect(TokenValidator.validateRefNumber(string: thirdPartWrong)).toNot(beTrue())
                }
                it("immobilisation components") {
                    let part1Correct = "123"
                    let part2Correct = "1"
                    let part3Correct = "789"
                    let part1LengthWrong = "7777777"
                    let part2LengthWrong = "22"
                    let part3LengthWrong = "7777777"
                    let part1Invliad = "0"
                    let part2Invliad = "3"
                    let part3Invliad = "0"

                    expect(TokenValidator.isValidIMReference(text: part1Correct, component: 0)).to(beTrue())
                    expect(TokenValidator.isValidIMReference(text: part2Correct, component: 1)).to(beTrue())
                    expect(TokenValidator.isValidIMReference(text: part3Correct, component: 2)).to(beTrue())

                    expect(TokenValidator.isValidIMReference(text: part1LengthWrong, component: 0)).toNot(beTrue())
                    expect(TokenValidator.isValidIMReference(text: part2LengthWrong, component: 1)).toNot(beTrue())
                    expect(TokenValidator.isValidIMReference(text: part3LengthWrong, component: 2)).toNot(beTrue())

                    expect(TokenValidator.isValidIMReference(text: part1Invliad, component: 0)).toNot(beTrue())
                    expect(TokenValidator.isValidIMReference(text: part2Invliad, component: 1)).toNot(beTrue())
                    expect(TokenValidator.isValidIMReference(text: part3Invliad, component: 2)).toNot(beTrue())
                }
            }

            context("vehicle registration") {
                it("Only digit and Capital") {
                    let correct = "LD44HHH"
                    let incorrectSpace = "LD44 HHH"
                    let incorrectLower = "LD44hhh"
                    let numberTooLong = "ASDFGHJKLQWERT"
                    expect(TokenValidator.validateVehicleReg(string: correct)).to(beTrue())
                    expect(TokenValidator.validateVehicleReg(string: incorrectSpace)).toNot(beTrue())
                    expect(TokenValidator.validateVehicleReg(string: incorrectLower)).toNot(beTrue())
                    expect(TokenValidator.validateVehicleReg(string: numberTooLong)).toNot(beTrue())
                }
                it("'vehicle' and 'Reg No.' should be removed") {
                    let wrongV = "vehicle HSD123 "
                    let wrongR = "Reg No: LD123 "
                    expect(TokenValidator.validateVehicleReg(string: wrongV)).toNot(beTrue())
                    expect(TokenValidator.validateVehicleReg(string: wrongR)).toNot(beTrue())
                }
            }

            context("date") {
                it("UK format only") {
                    let cnFormat = "2012/12/12"
                    expect(TokenValidator.validateDate(string: cnFormat)).toNot(beTrue())
                }
                it("numbers only") {
                    let letterFormat = "12/JUN/2019"
                    expect(TokenValidator.validateDate(string: letterFormat)).toNot(beTrue())
                }
                it("Date range") {
                    let tooEarly = "01/01/1970"
                    let future = "01/01/3001"
                    expect(TokenValidator.validateDate(string: tooEarly)).toNot(beTrue())
                    expect(TokenValidator.validateDate(string: future)).toNot(beTrue())
                }
            }

            context("penalty amount") {
                it("numbers only, £ symbol should be removed") {
                    let correct = "1234"
                    let wrong = "£50"
                    let tooShort = "1"
                    let tooLong = "55555"
                    expect(TokenValidator.validatePenaltyAmount(string: correct)).to(beTrue())
                    expect(TokenValidator.validatePenaltyAmount(string: wrong)).toNot(beTrue())
                    expect(TokenValidator.validatePenaltyAmount(string: tooShort)).toNot(beTrue())
                    expect(TokenValidator.validatePenaltyAmount(string: tooLong)).toNot(beTrue())
                }
            }
        }
        describe("validateValue") {
            context("validate value") {
                it("ref number") {
                    let indexPath = IndexPath(row: 0, section: 0)
                    let validateValue = TokenValidator.validateDateAndRef(string: "123-1-123-IM", indexPath: indexPath)
                    let validateRef = TokenValidator.validateRefNumber(string: "123-1-123-IM")
                    expect(validateValue).to(equal(validateRef))
                }
                it("reg number") {
                    let indexPath = IndexPath(row: 1, section: 0)
                    let validateValue = TokenValidator.validateDateAndRef(string: "LD17 666", indexPath: indexPath)
                    expect(validateValue).to(beTrue())
                }
                it("date") {
                    let indexPath = IndexPath(row: 2, section: 0)
                    let validateValue = TokenValidator.validateDateAndRef(string: "01/01/2017", indexPath: indexPath)
                    let validateDate = TokenValidator.validateDate(string: "01/01/2017")
                    expect(validateValue).to(equal(validateDate))
                }
                it("amount") {
                    let indexPath = IndexPath(row: 3, section: 0)
                    let validateValue = TokenValidator.validateDateAndRef(string: "150", indexPath: indexPath)
                    expect(validateValue).to(beTrue())
                }
            }
        }
    }
}
