//
//  AWSBodyListModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 02/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSBodyListModelSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSGetDocumentsResponse")
        }

        describe("AWSBodyListModel") {
            context("encode") {
                it("should match keys") {
                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSBodyListModel.self)

                    let bodyList = adapter?.model as? AWSBodyListModel
                    expect(bodyList).toNot(beNil())
                    expect(bodyList?.items?.count).to(equal(102))
                    expect(bodyList?.nextOperation?.nextID).to(equal("1234567890121_FPN"))
                    expect(bodyList?.nextOperation?.nextOffset).toNot(beNil())

                    expect(bodyList?.all().count).to(equal(102))
                    expect(bodyList?.item(at: 0)).toNot(beNil())
                    expect(bodyList?.item(at: -1)).to(beNil())
                    expect(bodyList?.item(at: 102)).to(beNil())
                }
            }

            context("decode") {
                it("should match keys") {

                     let body = AWSBodyModel()!
                    body.enabled = true
                    body.key = "ue2wiuio"
                    body.offset = Date(timeIntervalSince1970: 1476180721)
                    body.hashToken = "3iuy12iuy3iu1"
                    body.value = AWSDocumentModel()

                    let bodyList = AWSBodyListModel()
                    bodyList?.items = [body]
                    let nextIndex = AWSNextIndexModel()
                    nextIndex?.nextID = "myKey"
                    nextIndex?.nextOffset = Date(timeIntervalSince1970: 1476180721)
                    bodyList?.nextOperation = nextIndex

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: bodyList) as? [String: Any]
                    expect(myDictionary).toNot(beNil())
                    expect(myDictionary?["Items"]).toNot(beNil())

                    let dictionary = myDictionary?["LastEvaluatedKey"] as? [String: AnyObject]
                    expect(dictionary?["ID"] as? String).to(equal("myKey"))
                    expect(dictionary?["Offset"] as? TimeInterval).to(equal(1476180721))

                    expect(myDictionary?.count).to(equal(2))
                }
            }
        }
    }
}
