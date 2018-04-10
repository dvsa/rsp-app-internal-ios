//
//  TabFlowControllerSpecs.swift
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

class TabFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("TabFlowController") {

            let navigationController = UINavigationController()
            let flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)
            var tabBarFlowController: TabFlowController?
            var authUIPresenterFlowMock: AuthUIPresenterFlow?

            beforeEach {
                authUIPresenterFlowMock = AuthUIPresenterFlowMock()
                tabBarFlowController = TabFlowController(configure: flowConfigure)
            }

            context("init") {
                it("should not be nil") {
                    expect(tabBarFlowController).toNot(beNil())
                }
                it("should set configure as main") {
                    expect(tabBarFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("when start") {
                beforeEach {
                    tabBarFlowController?.delegate = authUIPresenterFlowMock
                    tabBarFlowController?.start()
                }
                it("should not set window") {
                    expect(tabBarFlowController?.configure.window).to(beNil())
                }
                it("should set navigation") {
                    expect(tabBarFlowController?.configure.navigationController).toNot(beNil())
                }
                it("should set all child flows") {
                    expect(tabBarFlowController?.childFlows[Route.tokenList.rawValue]).toNot(beNil())
                    expect(tabBarFlowController?.childFlows[Route.newToken.rawValue]).toNot(beNil())
                    expect(tabBarFlowController?.childFlows[Route.settings.rawValue]).toNot(beNil())
                    expect(tabBarFlowController?.childFlows.count).to(equal(3))
                }
                it("should set navigation controllers for child flow") {

                    let tokensFlowController = tabBarFlowController?.childFlows[Route.tokenList.rawValue] as? TokensFlowController
                    expect(tokensFlowController).toNot(beNil())
                    expect(tokensFlowController?.configure.navigationController).toNot(beNil())
                    expect(tokensFlowController?.configure.navigationController?.tabBarItem.title).toNot(beNil())
                    expect(tokensFlowController?.configure.navigationController?.tabBarItem.image).toNot(beNil())
                    expect(tokensFlowController?.delegate).toNot(beNil())

                    let newTokenFlowController = tabBarFlowController?.childFlows[Route.newToken.rawValue] as? NewTokenFlowController
                    expect(newTokenFlowController).toNot(beNil())
                    expect(newTokenFlowController?.configure.navigationController).toNot(beNil())
                    expect(newTokenFlowController?.configure.navigationController?.tabBarItem.title).toNot(beNil())
                    expect(newTokenFlowController?.configure.navigationController?.tabBarItem.image).toNot(beNil())
                }

                it("should set all 4 tabs") {
                    expect(tabBarFlowController?.childNavControllers).toNot(beNil())
                    expect(tabBarFlowController?.childNavControllers.count).to(equal(3))
                }

                it("should set all 4 flows") {
                    expect(tabBarFlowController?.childFlows.count).to(equal(3))
                }

                it("should setup TokensFlowController") {
                    let flow = tabBarFlowController?.childFlows[Route.tokenList.rawValue] as? TokensFlowController
                    expect(flow).toNot(beNil())
                    expect(flow?.delegate).toNot(beNil())
                }

                it("should setup NewTokenFlowController") {
                    let flow = tabBarFlowController?.childFlows[Route.newToken.rawValue] as? NewTokenFlowController
                    expect(flow).toNot(beNil())
                }

                it("should setup SettingsFlowController") {
                    let flow = tabBarFlowController?.childFlows[Route.settings.rawValue] as? SettingsFlowController
                    expect(flow).toNot(beNil())
                    expect(flow?.delegate).toNot(beNil())
                }

                it("should setup tabController") {
                    expect(tabBarFlowController?.tabBarController).toNot(beNil())
                }
            }

            context("navigationHandler") {
                it("should route config") {
                    let location = Location(path: "config", arguments: [:], payload: nil)
                    tabBarFlowController?.navigationHandler?(location)
                }
            }

        }

    }
}
