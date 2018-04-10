//
//  BodyObjectSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//Copyright © 2017 Andrea Scuderi. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class BodyObjectSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        var dictionary: [String: Any]?
        var bodyModel: AWSBodyModel!

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSBody")
            let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSBodyModel.self)
            bodyModel = adapter?.model as? AWSBodyModel
        }

        describe("BodyObject") {
            context("init") {
                it("should init with AWSBodyModel") {

                    let body = BodyObject(model: bodyModel)
                    expect(body).toNot(beNil())
                }
            }

            context("init with Document Object") {
                it("should init when referenceNo and penaltyType are valid") {
                    let document = DocumentObject()
                    document.setKey(referenceNo: "7176387", penaltyType: PenaltyType.fpn)
                    let penaltyType = document.getPenaltyType()!.toString()

                    let body = BodyObject(object: document)
                    expect(body).toNot(beNil())
                    expect(body?.key).to(equal("\(document.referenceNo)_\(penaltyType)"))
                    expect(body?.enabled).to(beTrue())
                    expect(body?.hashToken).to(equal("New"))
                    expect(body?.value).to(equal(document))

                }

                it("should not init when referenceNo and penaltyType are invalid") {
                    let document = DocumentObject()
                    document.referenceNo = ""
                    let body = BodyObject(object: document)
                    expect(body).to(beNil())
                }
            }

            context("extension") {
                it("should init with AWSBodyModel") {
                    if let body = BodyObject(model: bodyModel) {
                        let model = AWSBodyModel(object: body)
                        expect(body).toNot(beNil())
                        expect(body.key).to(equal(model.key))
                        expect(body.hashToken).to(equal(model.hashToken))
                        expect(body.offset).to(equal(model.offset))
                        expect(body.value?.isEqualToModel(model: model.value!)).to(beTrue())
                        expect(body.enabled).to(equal(model.enabled?.boolValue))
                    } else {
                        fail()
                    }
                }
            }
        }
    }
}
