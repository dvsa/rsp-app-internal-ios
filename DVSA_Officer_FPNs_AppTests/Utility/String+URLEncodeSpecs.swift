//
//  String+URLEncodeSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Nimble
import Quick

@testable import DVSA_Officer_FPNs_App

class StringURLEncodeSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("String") {
            context("urlEncoded") {
                it("should encode") {
                    let url = "www.example.com/path with space/text?78890.zip"
                    let urlEncoded = url.urlEncoded()
                    expect(urlEncoded).toNot(beNil())
                    expect(urlEncoded).to(equal("www.example.com/path%20with%20space/text?78890.zip"))
                }
            }
            context("urlDecoded") {
                it("should decode") {
                    let urlEncoded = "www.example.com/path%20with%20space/text?78890.zip"
                    let url = urlEncoded.urlDecoded()
                    expect(url).toNot(beNil())
                    expect(url).to(equal("www.example.com/path with space/text?78890.zip"))
                }
            }

            context("splitedBy") {
                it("should split by length") {
                    let array = "01230123012312".splitedBy(length: 4)
                    expect(array).toNot(beNil())
                    expect(array.count).to(equal(4))
                    expect(array[0]).to(equal("0123"))
                    expect(array[1]).to(equal("0123"))
                    expect(array[2]).to(equal("0123"))
                    expect(array[3]).to(equal("12"))
                }
            }

            context("insert") {
                it("should insert string every lenght characters") {
                    let value = "01230123012312".insert(separator: "-", lenght: 4)
                    expect(value).toNot(beNil())
                    expect(value).to(equal("0123-0123-0123-12"))
                }
            }

            context("isValidPhoneNumber") {
                it("should validate phone number") {

                    let num1  = "+90294038904"
                    expect(num1.isValidPhoneNumber()).to(beTrue())

                    let num2  = "+44029403890"
                    expect(num2.isValidPhoneNumber()).to(beTrue())

                    let num3  = "+9029"
                    expect(num3.isValidPhoneNumber()).to(beFalse())

                    let num4  = "+(00) 9029"
                    expect(num4.isValidPhoneNumber()).to(beFalse())
                }
            }

            context("isValidEmail") {
                it("should validate email") {

                    let mail1  = "james.moriarty@example.com"
                    expect(mail1.isValidEmail()).to(beTrue())

                    let mail2  = "james.moriarty@example"
                    expect(mail2.isValidEmail()).to(beFalse())

                    let mail3  = "james.moriarty.example.com"
                    expect(mail3.isValidEmail()).to(beFalse())
                }
            }

            context("IM token string") {
                it("should remove all - and IM") {
                    let refIM = "123-1-666-IM"
                    let refIM6Long = "123456-1-666-IM"
                    let refIM0Long = "123456-0-666-IM"
                    let wrongFormat = "1234-1-666"
                    let tooLong = "1234567-1-666-IM"
                    let tooLong2 = "123456-12-666-IM"
                    let tooLong3 = "123456-1-6667777-IM"
                    let wrongFormat1 = "123456-2-6667777-IM"
                    expect(refIM.immobTokenRef(type: PenaltyType.immobilization)).to(equal("0001231000666"))
                    expect(refIM6Long.immobTokenRef(type: PenaltyType.immobilization)).to(equal("1234561000666"))
                    expect(refIM0Long.immobTokenRef(type: PenaltyType.immobilization)).to(equal("1234560000666"))
                    expect(wrongFormat.immobTokenRef(type: PenaltyType.immobilization)).to(beNil())
                    expect(tooLong.immobTokenRef(type: PenaltyType.immobilization)).to(beNil())
                    expect(tooLong2.immobTokenRef(type: PenaltyType.immobilization)).to(beNil())
                    expect(tooLong3.immobTokenRef(type: PenaltyType.immobilization)).to(beNil())
                    expect(wrongFormat1.immobTokenRef(type: PenaltyType.immobilization)).to(beNil())
                }
            }

            context("truncated") {
                it("should trouncate") {
                    let string = "12345678900987654321aabcdef"
                    let truncated = string.truncated(limit: 10)
                    expect(truncated).to(equal("1234567890..."))
                }
            }
        }
    }
}
