//
//  AWSSiteModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSSiteModelSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?
        var items: [[String: Any]]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSSites")
            items = dictionary?["Items"] as? [[String: Any]]
        }

        describe("AWSSiteModel") {
            context("encode") {
                it("should match keys") {

                    let object = items?[0]
                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: object, modelClass: AWSSiteModel.self)

                    let site = adapter?.model as? AWSSiteModel
                    expect(site).toNot(beNil())

                    expect(site?.name).to(equal("Abingdon (A34/41 interchange - South of Oxford)"))
                    expect(site?.region).to(equal("South East"))
                    expect(site?.siteCode).to(equal(1))

                }
            }

            context("decode") {
                it("should match keys") {

                    let site = AWSSiteModel()
                    site?.name = "Test Name"
                    site?.siteCode = 200
                    site?.region = "South East"

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: site) as? [String: Any]
                    expect(myDictionary).toNot(beNil())
                    expect(myDictionary?["name"] as? String).to(equal("Test Name"))
                    expect(myDictionary?["region"] as? String).to(equal("South East"))
                    let siteCode = myDictionary?["siteCode"] as? NSNumber
                    expect(siteCode?.intValue).to(equal(200))
                    expect(myDictionary?.count).to(equal(3))
                }
            }
        }
    }
}
