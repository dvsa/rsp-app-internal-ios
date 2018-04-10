//
//  RegexSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 25/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Nimble
import Quick

@testable import DVSA_Officer_FPNs_App

class RegexSpecs: QuickSpec {
    override func spec() {

        let regex = Regex(regex: "\\d+")
        let testNumbers = "11 asdf 12345 sdf 333"

        describe("Regex") {
            context("Init") {
                it("should not be nil") {
                    expect(regex).toNot(beNil())
                }
                it("regex string set") {
                    expect(regex.regexString).to(equal("\\d+"))
                }
            }
            context("regex filtering") {
                let result = regex.regexMatches(text: testNumbers)
                it("find all matches") {
                    expect(result.count).to(equal(3))
                    expect(result[0]).to(equal("11"))
                    expect(result[1]).to(equal("12345"))
                    expect(result[2]).to(equal("333"))
                }
                it("find first match") {
                    expect(regex.firstMatchedText(text: testNumbers)).to(equal("11"))
                }
            }
            context("reference number") {
                let refRegex = Regex(regex: DetailsRowData.refNumber.regexString)
                let ref12 = "123456789012"
                let ref13 = "1234567890123"
                let refIM = "1234-1-988-IM"
                let wrongRefShort = "12345"
                let wrongRefLong = "1236478887162547"
                let wrongRefFormat = "12345-12-IM"

                it("12 lenth numbers") {
                    expect(refRegex.firstMatchedText(text: ref12)).toNot(beNil())
                }
                it("13 lenth numbers") {
                    expect(refRegex.firstMatchedText(text: ref13)).toNot(beNil())
                }
                it("IM ref") {
                    expect(refRegex.firstMatchedText(text: refIM)).toNot(beNil())
                }
                it("short lenth numbers") {
                    expect(refRegex.firstMatchedText(text: wrongRefShort)).to(beNil())
                }
                it("long lenth numbers match first part") {
                    expect(refRegex.firstMatchedText(text: wrongRefLong)).toNot(beNil())
                }
                it("wrong format") {
                    expect(refRegex.firstMatchedText(text: wrongRefFormat)).to(beNil())
                }
            }
            context("vehicle registration") {
                let vehicleRegRegex = Regex(regex: DetailsRowData.vehicleReg.regexString)
                let imReg = "vehicle 12JHS "
                let fpnReg = "Reg No: 123JH "
                let wrongLowerCase = "vehicle 12sdJ "
                let wrongFormat = "123JHS"

                it("IM reg") {
                    expect(vehicleRegRegex.firstMatchedText(text: imReg)).toNot(beNil())
                }
                it("FPN reg") {
                    expect(vehicleRegRegex.firstMatchedText(text: fpnReg)).toNot(beNil())
                }
                it("lower case") {
                    expect(vehicleRegRegex.firstMatchedText(text: wrongLowerCase)).to(beNil())
                }
                it("wrong format") {
                    expect(vehicleRegRegex.firstMatchedText(text: wrongFormat)).to(beNil())
                }
            }
            context("date") {
                let dateRegex = Regex(regex: DetailsRowData.date.regexString)
                let dateString = "03/05/2019"

                it("date format") {
                    expect(dateRegex.firstMatchedText(text: dateString)).toNot(beNil())
                }
            }
            context("penalty amount") {
                let penaltyRegex = Regex(regex: DetailsRowData.penaltyAmount.regexString)
                let correctFormat = "£123"
                let wrongFormat = "12345"

                it("right format") {
                    expect(penaltyRegex.firstMatchedText(text: correctFormat)).toNot(beNil())
                }
                it("wrong format") {
                    expect(penaltyRegex.firstMatchedText(text: wrongFormat)).to(beNil())
                }
            }
        }
    }
}
