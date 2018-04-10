//
//  TrailerDetailsObjectSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class TrailerDetailsObjectSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?
        var trailerDetailModel: AWSTrailerDetailsModel!

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument", with: "trailerDetails")
            let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSTrailerDetailsModel.self)
            trailerDetailModel = adapter?.model as? AWSTrailerDetailsModel
        }

        describe("DocumentObject") {
            context("init") {
                it("should init with AWSDocumentModel") {

                    let trailerDetails = TrailerDetailsObject(model: trailerDetailModel)
                    expect(trailerDetails).toNot(beNil())
                }
            }

            context("extension") {
                it("should init with AWSDocumentModel") {
                    if let trailerDetails = TrailerDetailsObject(model: trailerDetailModel) {
                        let model = AWSTrailerDetailsModel(object: trailerDetails)
                        expect(trailerDetails).toNot(beNil())
                        expect(trailerDetails.number1).to(equal(model.number1))
                        expect(trailerDetails.number2).to(equal(model.number2))

                        expect(trailerDetails.isEqualToModel(model: model)).to(beTrue())
                    } else {
                        fail()
                    }
                }
            }
        }
    }
}
