//
//  NewTokenModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 05/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
@testable import DVSA_Officer_FPNs_App

class NewTokenModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("NewTokenModel") {
            context("init") {
                it("should init a new object") {
                    let obj1 = NewTokenModel(value: nil)
                    expect(obj1.referenceNo).to(equal(""))
                    expect(obj1.penaltyType).to(equal(PenaltyType.fpn))
                    expect(obj1.vehicleRegNo).to(equal(""))
                    expect(obj1.penaltyAmount).to(equal(""))
                    expect(obj1.dateTime).to(beNil())
                }

                it("with value should init a new object") {
                    let obj1 = NewTokenModel(value: nil)
                    expect(obj1.referenceNo).to(equal(""))
                    expect(obj1.penaltyType).to(equal(PenaltyType.fpn))
                    expect(obj1.vehicleRegNo).to(equal(""))
                    expect(obj1.penaltyAmount).to(equal(""))
                    expect(obj1.dateTime).to(beNil())

                    obj1.referenceNo = "1283127"
                    obj1.penaltyAmount = "980"
                    obj1.penaltyType = PenaltyType.immobilization
                    obj1.vehicleRegNo = "76153276"
                    obj1.dateTime = Date()

                    let obj2 = NewTokenModel(value: obj1)
                    expect(obj2.referenceNo).to(equal("1283127"))
                    expect(obj2.penaltyType).to(equal(PenaltyType.immobilization))
                    expect(obj2.vehicleRegNo).to(equal("76153276"))
                    expect(obj2.penaltyAmount).to(equal("980"))
                    expect(obj2.dateTime).toNot(beNil())

                    obj1.referenceNo = "132132"
                    obj1.penaltyAmount = "213"
                    obj1.penaltyType = PenaltyType.fpn
                    obj1.vehicleRegNo = "23131"
                    obj1.dateTime = Date()

                    expect(obj2.referenceNo).to(equal("1283127"))
                    expect(obj2.penaltyType).to(equal(PenaltyType.immobilization))
                    expect(obj2.vehicleRegNo).to(equal("76153276"))
                    expect(obj2.penaltyAmount).to(equal("980"))
                    expect(obj2.dateTime).toNot(beNil())

                }
            }
        }
    }
}
