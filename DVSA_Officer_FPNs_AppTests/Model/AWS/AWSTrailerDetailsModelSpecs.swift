//
//  AWSTrailerDetailsModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSTrailerDetailsModelSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument", with: "trailerDetails")
        }

        describe("AWSTrailerDetailsModel") {
            context("encode") {
                it("should match keys") {
                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSTrailerDetailsModel.self)

                    let trailerDetails = adapter?.model as? AWSTrailerDetailsModel
                    expect(trailerDetails).toNot(beNil())
                    expect(trailerDetails?.number1).to(equal("1"))
                    expect(trailerDetails?.number2).to(equal("2"))
                }
            }

            context("decode") {
                it("should match keys") {

                    let trailerDetails = AWSTrailerDetailsModel()
                    trailerDetails?.number1 = "my number1"
                    trailerDetails?.number2 = "my number2"

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: trailerDetails) as? [String: Any]
                    expect(myDictionary).toNot(beNil())
                    expect(myDictionary?["number1"] as? String).to(equal("my number1"))
                    expect(myDictionary?["number2"] as? String).to(equal("my number2"))

                    expect(myDictionary?.count).to(equal(2))
                }
            }
        }
    }
}
