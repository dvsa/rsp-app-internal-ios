//
//  SiteObjectListViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 19/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class SiteObjectListViewModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("SiteObjectListViewModel") {

            var datasourceMock: PersistentDataSourceMock!

            beforeEach {
                datasourceMock = PersistentDataSourceMock()

                let site = SiteObject()
                site.name = "Area 1"
                site.code = -1
                site.region = SiteRegion.mobile.rawValue

                let site2 = SiteObject()
                site2.name = "Site 1"
                site2.code = 1
                site2.region = SiteRegion.western.rawValue

                datasourceMock.sitesObjects = [site, site2]
            }

            context("init") {
                it("should filter sites") {
                    let viewModel = SiteObjectListViewModel(datasource: datasourceMock, isMobile: false)
                    expect(viewModel.isMobile).to(beFalse())
                    expect(viewModel.model.items?.count).to(equal(1))
                }

                it("should filter sites") {
                    let viewModel = SiteObjectListViewModel(datasource: datasourceMock, isMobile: true)
                    expect(viewModel.isMobile).to(beTrue())
                    expect(viewModel.model.items?.count).to(equal(1))
                }
            }

            context("update") {
                it("should filter sites") {
                    let viewModel = SiteObjectListViewModel(datasource: datasourceMock, isMobile: false)
                    expect(viewModel.isMobile).to(beFalse())
                    expect(viewModel.model.items?.count).to(equal(1))

                    let site = SiteObject()
                    site.name = "Area 1"
                    site.code = -1
                    site.region = SiteRegion.mobile.rawValue

                    let site2 = SiteObject()
                    site2.name = "Area 2"
                    site2.code = -2
                    site2.region = SiteRegion.mobile.rawValue

                    viewModel.update(items: [site2, site])
                    expect(viewModel.model.items?.count).to(equal(0))
                }

                it("should filter sites") {
                    let viewModel = SiteObjectListViewModel(datasource: datasourceMock, isMobile: true)
                    expect(viewModel.isMobile).to(beTrue())
                    expect(viewModel.model.items?.count).to(equal(1))

                    let site = SiteObject()
                    site.name = "Area 1"
                    site.code = -1
                    site.region = SiteRegion.mobile.rawValue

                    let site2 = SiteObject()
                    site2.name = "Area 2"
                    site2.code = -2
                    site2.region = SiteRegion.mobile.rawValue

                    viewModel.update(items: [site2, site])
                    expect(viewModel.model.items?.count).to(equal(2))
                }
            }
        }
    }
}
