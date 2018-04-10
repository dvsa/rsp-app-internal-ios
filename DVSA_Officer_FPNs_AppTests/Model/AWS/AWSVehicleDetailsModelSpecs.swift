//
//  AWSVehicleDetailsModelSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/11/2017.
//Copyright © 2017 Andrea Scuderi. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSVehicleDetailsModelSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument", with: "vehicleDetails")
        }

        describe("AWSVehicleDetailsModel") {
            context("encode") {
                it("should match keys") {
                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSVehicleDetailsModel.self)

                    let vehicleDetails = adapter?.model as? AWSVehicleDetailsModel
                    expect(vehicleDetails).toNot(beNil())
                    expect(vehicleDetails?.regNo).to(equal("XXXXXXX"))
                    expect(vehicleDetails?.nationality).to(equal("UK"))
                    expect(vehicleDetails?.make).to(equal("Rolls Royce"))
                }
            }

            context("decode") {
                it("should match keys") {

                    let vehicleDetails = AWSVehicleDetailsModel()
                    vehicleDetails?.make = "myMake"
                    vehicleDetails?.nationality = "myNationality"
                    vehicleDetails?.regNo = "myRegNo"

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: vehicleDetails) as? [String: Any]
                    expect(myDictionary).toNot(beNil())
                    expect(myDictionary?["regNo"] as? String).to(equal("myRegNo"))
                    expect(myDictionary?["nationality"] as? String).to(equal("myNationality"))
                    expect(myDictionary?["make"] as? String).to(equal("myMake"))

                    expect(myDictionary?.count).to(equal(3))
                }
            }
        }
    }
}
