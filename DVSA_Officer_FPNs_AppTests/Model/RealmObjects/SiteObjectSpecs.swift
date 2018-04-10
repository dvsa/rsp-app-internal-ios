//
//  SiteObjectSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class SiteObjectSpecs: QuickSpec {

    override func spec() {

        var siteModel: AWSSiteModel!

        beforeEach {
            siteModel = DataMock.shared.siteModel
        }

        describe("SiteObject") {
            context("init") {
                it("should init with AWSBodyModel") {
                    let site = SiteObject(model: siteModel)
                    expect(site).toNot(beNil())
                }
            }

            context("extension") {
                it("should init with AWSBodyModel") {
                    if let site = SiteObject(model: siteModel) {
                        let model = AWSSiteModel(object: site)
                        expect(site).toNot(beNil())
                        expect(site.name).to(equal(model.name))
                        expect(site.code).to(equal(model.siteCode?.intValue))
                        expect(site.region).to(equal(model.region))
                        expect(site.key()).to(equal(model.siteCode?.intValue))
                    } else {
                        fail()
                    }
                }
            }
        }
    }
}
