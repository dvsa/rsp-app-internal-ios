//
//  AWSNotifyEmailModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSNotifyEmailModelSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSNotifyEmail")
        }

        describe("AWSNotifySMS") {
            context("encode") {
                it("should match keys") {

                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSNotifyEmailModel.self)

                    let notifyEmail = adapter?.model as? AWSNotifyEmailModel
                    expect(notifyEmail).toNot(beNil())

                    expect(notifyEmail?.email).to(equal("james.moriarty@localhost.co.uk"))
                    expect(notifyEmail?.vehicleReg).to(equal("0000000"))
                    expect(notifyEmail?.amount?.int16Value).to(equal(10))
                    expect(notifyEmail?.location).to(equal("London"))
                    expect(notifyEmail?.token).to(equal("0123456789abcdef"))
                }
            }

            context("decode") {
                it("should match keys") {

                    let notifyEmail = AWSNotifyEmailModel()
                    notifyEmail?.email = "james.moriarty@localhost.co.uk"
                    notifyEmail?.vehicleReg = "XXXXXX"
                    notifyEmail?.amount = NSNumber(value: 1000)
                    notifyEmail?.location = "Nottingham"
                    notifyEmail?.token = "0123456789abcdef"

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: notifyEmail) as? [String: Any]
                    expect(myDictionary).toNot(beNil())
                    expect(myDictionary?["Email"] as? String).to(equal("james.moriarty@localhost.co.uk"))
                    expect(myDictionary?["VehicleReg"] as? String).to(equal("XXXXXX"))
                    expect(myDictionary?["Location"] as? String).to(equal("Nottingham"))
                    let amount = myDictionary?["Amount"] as? NSNumber
                    expect(amount?.int16Value).to(equal(1000))
                    expect(myDictionary?["Token"] as? String).to(equal("0123456789abcdef"))
                    expect(myDictionary?.count).to(equal(5))
                }
            }
        }
    }
}
