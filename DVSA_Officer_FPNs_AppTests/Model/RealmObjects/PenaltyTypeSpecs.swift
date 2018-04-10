//
//  PenaltyTypeSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 02/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class PenaltyTypeSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("PenaltyTypeSpecs") {
            context("type") {
                it("should code the rawValue") {
                    expect(PenaltyType.fpn.rawValue).to(equal(0))
                    expect(PenaltyType.immobilization.rawValue).to(equal(1))
                    expect(PenaltyType.deposit.rawValue).to(equal(2))
                    expect(PenaltyType(rawValue: 3)).to(beNil())
                }
            }

            context("value") {
                it("should return a valid PenaltyType") {
                    expect(PenaltyType.value(from: "FPN")?.rawValue).to(equal(0))
                    expect(PenaltyType.value(from: "IM")?.rawValue).to(equal(1))
                    expect(PenaltyType.value(from: "CDN")?.rawValue).to(equal(2))
                    expect(PenaltyType.value(from: "fpn")).to(beNil())
                    expect(PenaltyType.value(from: "immobilization")).to(beNil())
                    expect(PenaltyType.value(from: "cdn")).to(beNil())
                }
            }

            context("toString") {
                it("should return a valid PenaltyType") {
                    expect(PenaltyType.fpn.toString()).to(equal("FPN"))
                    expect(PenaltyType.immobilization.toString()).to(equal("IM"))
                    expect(PenaltyType.deposit.toString()).to(equal("CDN"))
                }
            }

            context("toExtendedString") {
                it("should return a valid PenaltyType") {
                    expect(PenaltyType.fpn.toExtendedString()).to(equal("Fixed penalty"))
                    expect(PenaltyType.immobilization.toExtendedString()).to(equal("Immobilisation"))
                    expect(PenaltyType.deposit.toExtendedString()).to(equal("Court deposit"))
                }
            }
        }

        describe("DocumentObject extension") {
            context("getPenaltyType") {
                it("should return a valid PenaltyType") {
                    let document = DocumentObject()
                    let defaultValue = document.getPenaltyType()?.rawValue
                    expect(PenaltyType.fpn.rawValue).to(equal(defaultValue))

                    document.penaltyType = 1
                    let im = document.getPenaltyType()?.rawValue
                    expect(PenaltyType.immobilization.rawValue).to(equal(im))

                    document.penaltyType = 2
                    let cdn = document.getPenaltyType()?.rawValue
                    expect(PenaltyType.deposit.rawValue).to(equal(cdn))

                    document.penaltyType = -1
                    let invalid = document.getPenaltyType()?.rawValue
                    expect(invalid).to(beNil())

                    document.penaltyType = 4
                    let invalid2 = document.getPenaltyType()?.rawValue
                    expect(invalid2).to(beNil())
                }
            }

            context("set PenaltyType and RefrenceNo") {
                it("should set a valid PenaltyType") {

                    let document = DocumentObject()

                    document.setKey(referenceNo: "1234567890123", penaltyType: PenaltyType.fpn)
                    expect(PenaltyType.fpn.rawValue).to(equal(UInt8(document.penaltyType)))
                    expect(document.referenceNo).to(equal("1234567890123"))
                    expect(document.key).to(equal("1234567890123_FPN"))

                    document.setKey(referenceNo: "123456-0-78901-IM", penaltyType: PenaltyType.immobilization)
                    expect(PenaltyType.immobilization.rawValue).to(equal(UInt8(document.penaltyType)))
                    expect(document.referenceNo).to(equal("123456-0-78901-IM"))
                    expect(document.key).to(equal("1234560078901_IM"))

                    document.setKey(referenceNo: "1234567890123", penaltyType: PenaltyType.deposit)
                    expect(PenaltyType.deposit.rawValue).to(equal(UInt8(document.penaltyType)))
                    expect(document.referenceNo).to(equal("1234567890123"))
                    expect(document.key).to(equal("1234567890123_CDN"))
                }
            }

        }
    }
}
