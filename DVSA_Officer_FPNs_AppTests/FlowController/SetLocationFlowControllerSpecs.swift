//
//  SetLocationFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 15/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit
import Compass
@testable import DVSA_Officer_FPNs_App

class SetLocationFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("SetLocationFlowController") {

            let navigationController = UINavigationController()
            let flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)
            var setLocationFlowController: SetLocationFlowController?

            var preferencesMock: PreferencesDataSourceMock!
            var datasourceMock: PersistentDataSourceMock!
            var synchManagerMock: SynchronizationManagerMock!

            beforeEach {
                preferencesMock = PreferencesDataSourceMock()
                datasourceMock = PersistentDataSourceMock()
                synchManagerMock = SynchronizationManagerMock()

                setLocationFlowController = SetLocationFlowController(configure: flowConfigure)
                setLocationFlowController?.preferences = preferencesMock
                setLocationFlowController?.synchManager = synchManagerMock
                setLocationFlowController?.datasource = datasourceMock
            }

            context("init") {
                it("should not be nil") {
                    expect(setLocationFlowController).toNot(beNil())
                }
                it("should set configure as main") {
                    expect(setLocationFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("when start") {
                beforeEach {
                    setLocationFlowController?.start()
                }
                it("should not set window") {
                    expect(setLocationFlowController?.configure.window).to(beNil())
                }
                it("should set navigation") {
                    expect(setLocationFlowController?.configure.navigationController).toNot(beNil())
                }
                it("should set siteLocationVC") {
                    expect(setLocationFlowController?.siteLocationVC).toNot(beNil())
                }

                it("should set setLocationVC") {
                    expect(setLocationFlowController?.setLocationVC).toNot(beNil())
                    expect(setLocationFlowController?.setLocationVC?.setLocationDelegate).toNot(beNil())
                }

                context("didSelect") {
                    it("should call sites") {
                        setLocationFlowController?.didSelect(key: 6)
                        expect(setLocationFlowController?.setLocationVC?.viewModel?.temporarySiteLocation).toNot(beNil())
                    }
                }
            }

            context("refreshData") {
                it("should call sites") {
                    let refreshData = self.expectation(description: "refreshData")

                    setLocationFlowController?.refreshData { (_) in
                        refreshData.fulfill()
                    }
                    self.wait(for: [refreshData], timeout: 10)
                    expect(synchManagerMock.done["sites"]).to(beTrue())
                }
            }

            context("didConfirmLocation") {

                it("should call updateSite") {
                    let site = SiteObject()
                    site.code = 7
                    site.name = "My Site"
                    setLocationFlowController?.didConfirmLocation(site: site, mobileAddress: nil)
                    expect(preferencesMock.done["updateSite"]).to(beTrue())
                }

                it("should not updateSite") {
                    setLocationFlowController?.didConfirmLocation(site: nil, mobileAddress: nil)
                    expect(preferencesMock.done["updateSite"]).to(beFalse())
                }
            }

        }
    }
}
