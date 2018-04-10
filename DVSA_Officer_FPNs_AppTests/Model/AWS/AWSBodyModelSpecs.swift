//
//  AWSBodyModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSBodyModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSBody")
        }

        describe("AWSBodyModel") {
            context("encode") {
                it("should match keys") {
                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSBodyModel.self)

                    let body = adapter?.model as? AWSBodyModel
                    expect(body).toNot(beNil())

                    expect(body?.enabled?.boolValue).to(beTrue())
                    expect(body?.key).to(equal("820500000877"))
                    expect(body?.offset?.timeIntervalSince1970).to(equal(1511450735197))
                    expect(body?.value).toNot(beNil())
                    expect(body?.hashToken).to(equal("74ff0086e24d6035e8cc59e010f97940677ac1decd81de24f13a335507536261"))
                }
            }

            context("mapping") {
                it("should map jsonKeyPathsByPropertyKey") {

                    let params = AWSBodyModel.jsonKeyPathsByPropertyKey()!
                    expect(params.count).to(equal(5))
                    expect(params["key"] as? String).to(equal("ID"))
                    expect(params["value"] as? String).to(equal("Value"))
                    expect(params["hashToken"] as? String).to(equal("Hash"))
                    expect(params["offset"] as? String).to(equal("Offset"))
                    expect(params["enabled"] as? String).to(equal("Enabled"))
                }
            }

            context("decode") {
                it("should match keys") {

                    let body = AWSBodyModel()
                    body?.enabled = true
                    body?.key = "ue2wiuio"
                    body?.offset = Date(timeIntervalSince1970: 1476180721)
                    body?.hashToken = "3iuy12iuy3iu1"
                    body?.value = AWSDocumentModel()

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: body) as? [String: Any]
                    expect(myDictionary).toNot(beNil())

                    let enabled = myDictionary?["Enabled"] as? NSNumber
                    expect(enabled?.boolValue).to(beTrue())

                    expect(myDictionary?["ID"] as? String).to(equal("ue2wiuio"))

                    let offset = myDictionary?["Offset"] as? NSNumber
                    expect(offset?.doubleValue).to(equal(1476180721))

                    expect(myDictionary?["Hash"] as? String).to(equal("3iuy12iuy3iu1"))

                    expect(myDictionary?["Value"]).toNot(beNil())

                    expect(myDictionary?.count).to(equal(5))
                }
            }
        }
    }
}
