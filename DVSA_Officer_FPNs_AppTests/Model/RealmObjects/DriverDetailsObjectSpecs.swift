//
//  DriverDetailsObjectSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class DriverDetailsObjectSpecs: QuickSpec {
    override func spec() {
        var dictionary: [String: Any]?
        var driverDetailsModel: AWSDriverDetailsModel!

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument", with: "driverDetails")
            let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSDriverDetailsModel.self)
            driverDetailsModel = adapter?.model as? AWSDriverDetailsModel
        }

        describe("DocumentObject") {
            context("init") {
                it("should init with AWSDocumentModel") {

                    let driverDetails = DriverDetailsObject(model: driverDetailsModel)
                    expect(driverDetails).toNot(beNil())
                }
            }

            context("extension") {
                it("should init with AWSDocumentModel") {
                    if let driverDetails = DriverDetailsObject(model: driverDetailsModel) {
                        let model = AWSDriverDetailsModel(object: driverDetails)
                        expect(driverDetails).toNot(beNil())
                        expect(driverDetails.address).to(equal(model.address))
                        expect(driverDetails.licenceNumber).to(equal(model.licenceNumber))
                        expect(driverDetails.name).to(equal(model.name))

                        expect(driverDetails.isEqualToModel(model: model)).to(beTrue())
                    } else {
                        fail()
                    }
                }
            }
        }
    }
}
