//
//  AWSNotifySMSModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSNotifySMSModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSNotifySMS")
        }

        describe("AWSNotifySMS") {
            context("encode") {
                it("should match keys") {

                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSNotifySMSModel.self)

                    let notifySMS = adapter?.model as? AWSNotifySMSModel
                    expect(notifySMS).toNot(beNil())

                    expect(notifySMS?.phoneNumber).to(equal("+440000000000"))
                    expect(notifySMS?.vehicleReg).to(equal("XXXXXX"))
                    expect(notifySMS?.amount?.int16Value).to(equal(1000))
                    expect(notifySMS?.location).to(equal("Nottingham"))
                    expect(notifySMS?.token).to(equal("0123456789abcdef"))
                }
            }

            context("decode") {
                it("should match keys") {

                    let notifySMS = AWSNotifySMSModel()
                    notifySMS?.phoneNumber = "+440000000000"
                    notifySMS?.vehicleReg = "XXXXXX"
                    notifySMS?.amount = NSNumber(value: 1000)
                    notifySMS?.location = "Nottingham"
                    notifySMS?.token = "0123456789abcdef"

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: notifySMS) as? [String: Any]
                    expect(myDictionary).toNot(beNil())
                    expect(myDictionary?["PhoneNumber"] as? String).to(equal("+440000000000"))
                    expect(myDictionary?["VehicleReg"] as? String).to(equal("XXXXXX"))
                    expect(myDictionary?["Location"] as? String).to(equal("Nottingham"))
                    let amount = myDictionary?["Amount"] as? NSNumber
                    expect(amount?.int16Value).to(equal(1000))
                    expect(myDictionary?["Token"] as? String).to(equal("0123456789abcdef"))
                    expect(myDictionary?.count).to(equal(5))
                }
            }

            context("isValid") {
                it("should have all values") {

                    let notifySMS = AWSNotifySMSModel()
                    notifySMS?.phoneNumber = "+440000000000"
                    notifySMS?.vehicleReg = "XXXXXX"
                    notifySMS?.amount = NSNumber(value: 1000)
                    notifySMS?.location = "Nottingham"
                    notifySMS?.token = "0123456789abcdef"

                    expect(notifySMS?.isValid()).to(beTrue())

                    let notifySMS2 = AWSNotifySMSModel()
                    notifySMS2?.phoneNumber = "AW440000000000"
                    notifySMS2?.vehicleReg = "XXXXXX"
                    notifySMS2?.location = "Nottingham"

                    expect(notifySMS2?.isValid()).to(beFalse())

                }
            }
        }
    }
}
