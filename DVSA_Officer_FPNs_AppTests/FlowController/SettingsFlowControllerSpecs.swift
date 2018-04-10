//
//  SettingsFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 09/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit
import Compass
@testable import DVSA_Officer_FPNs_App

class SettingsFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("SettingsFlowController") {

            let navigationController = UINavigationController()
            let flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)
            var settingsFlowController: SettingsFlowController?
            let authUIDelegate = AuthUIPresenterFlowMock()

            beforeEach {
                settingsFlowController = SettingsFlowController(configure: flowConfigure)
            }

            context("init") {
                it("should not be nil") {
                    expect(settingsFlowController).toNot(beNil())
                }
                it("should set configure as main") {
                    expect(settingsFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("when start") {
                beforeEach {
                    settingsFlowController?.delegate = authUIDelegate
                    settingsFlowController?.start()
                }
                it("should not set window") {
                    expect(settingsFlowController?.configure.window).to(beNil())
                }
                it("should set navigation") {
                    expect(settingsFlowController?.configure.navigationController).toNot(beNil())
                }

                it("should set delegates") {
                    expect(settingsFlowController?.viewController?.setLocationDelegate).toNot(beNil())
                    expect(settingsFlowController?.viewController?.authUIDelegate).toNot(beNil())
                }
            }

            context("navigationHandler") {
            }
        }
    }
}
