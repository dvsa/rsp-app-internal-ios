//
//  AWSSiteListModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSSiteListModelSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSSites")
        }

        describe("AWSSiteListModel") {
            context("encode") {
                it("should match keys") {

                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSSiteListModel.self)

                    let siteList = adapter?.model as? AWSSiteListModel
                    expect(siteList).toNot(beNil())

                    expect(siteList?.items).toNot(beNil())
                    expect(siteList?.all().count).to(equal(77))
                    expect(siteList?.item(at: 0)).toNot(beNil())

                }
            }

            context("decode") {
                it("should match keys") {

                    let site = AWSSiteModel()!
                    site.name = "Test Name"
                    site.siteCode = 200
                    site.region = "South East"

                    let siteList = AWSSiteListModel()!
                    siteList.update(at: 0, item: site)

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: siteList) as? [String: Any]
                    expect(myDictionary).toNot(beNil())

                    let items = myDictionary?["Items"] as? [[String: Any]]
                    expect(items?.count).to(equal(1))

                    let item = items?[0]

                    expect(item?["name"] as? String).to(equal("Test Name"))
                    expect(item?["region"] as? String).to(equal("South East"))
                    let siteCode = item?["siteCode"] as? NSNumber
                    expect(siteCode?.intValue).to(equal(200))
                    expect(item?.count).to(equal(3))
                }
            }
        }
    }
}
