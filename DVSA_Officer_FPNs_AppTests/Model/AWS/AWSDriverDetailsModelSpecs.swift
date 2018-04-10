//
//  AWSDriverDetailsModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSDriverDetailsModelSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument", with: "driverDetails")
        }

        describe("AWSDriverDetailsModel") {
            context("encode") {
                it("should match keys") {
                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSDriverDetailsModel.self)

                    let driverDetails = adapter?.model as? AWSDriverDetailsModel
                    expect(driverDetails).toNot(beNil())
                    expect(driverDetails?.name).to(equal("James Moriarty"))
                    expect(driverDetails?.address).to(equal("1000 Baker Street, NW1 5LA, LONDON"))
                    expect(driverDetails?.licenceNumber).to(equal("MORIA801127JA09900"))
                }
            }

            context("decode") {
                it("should match keys") {

                    let driverDetails = AWSDriverDetailsModel()
                    driverDetails?.address = "my address"
                    driverDetails?.licenceNumber = "my licenceNumber"
                    driverDetails?.name = "my name"

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: driverDetails) as? [String: Any]
                    expect(myDictionary).toNot(beNil())
                    expect(myDictionary?["address"] as? String).to(equal("my address"))
                    expect(myDictionary?["licenceNumber"] as? String).to(equal("my licenceNumber"))
                    expect(myDictionary?["name"] as? String).to(equal("my name"))

                    expect(myDictionary?.count).to(equal(3))
                }
            }
        }
    }
}
