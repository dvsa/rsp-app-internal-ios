//
//  VehicleDetailsObjectSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class VehicleDetailsObjectSpecs: QuickSpec {

    override func spec() {
        var dictionary: [String: Any]?
        var vehicleDetailModel: AWSVehicleDetailsModel!

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument", with: "vehicleDetails")
            let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSVehicleDetailsModel.self)
            vehicleDetailModel = adapter?.model as? AWSVehicleDetailsModel
        }

        describe("DocumentObject") {
            context("init") {
                it("should init with AWSDocumentModel") {

                    let vehicleDetails = VehicleDetailsObject(model: vehicleDetailModel)
                    expect(vehicleDetails).toNot(beNil())
                }
            }

            context("extension") {
                it("should init with AWSDocumentModel") {
                    if let vehicleDetails = VehicleDetailsObject(model: vehicleDetailModel) {
                        let model = AWSVehicleDetailsModel(object: vehicleDetails)
                        expect(vehicleDetails).toNot(beNil())
                        expect(vehicleDetails.make).to(equal(model.make))
                        expect(vehicleDetails.nationality).to(equal(model.nationality))
                        expect(vehicleDetails.regNo).to(equal(model.regNo))
                    } else {
                        fail()
                    }
                }
            }
        }
    }
}
