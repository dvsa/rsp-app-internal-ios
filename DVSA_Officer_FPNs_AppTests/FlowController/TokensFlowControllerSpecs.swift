//
//  TokensFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/04/2018.
//Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import Compass

@testable import DVSA_Officer_FPNs_App

class TokensFlowControllerSpecs: QuickSpec {
    override func spec() {
        describe("TokensFlowController") {

            var navigationController: UINavigationController!
            var flowConfigure: FlowConfigure!
            var tokenFlowController: TokensFlowController?
            var presenterFlowMock: AuthUIPresenterFlowMock?

            beforeEach {
                navigationController = UINavigationController()
                flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)
                tokenFlowController = TokensFlowController(configure: flowConfigure)
                presenterFlowMock = AuthUIPresenterFlowMock()
                tokenFlowController?.delegate = presenterFlowMock
            }

            context("init") {
                it("should not be nil") {
                    expect(tokenFlowController).toNot(beNil())
                }
                it("should set configure as main") {
                    expect(tokenFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("when start") {
                beforeEach {
                    tokenFlowController?.start()
                    _ = tokenFlowController?.viewController?.view
                }

                it("should not set window") {
                    expect(tokenFlowController?.configure.window).to(beNil())
                }

                it("should set navigation") {
                    expect(tokenFlowController?.configure.navigationController).toNot(beNil())
                }

                it("should set the viewController") {
                    expect(tokenFlowController?.viewController).toNot(beNil())
                    let viewController = tokenFlowController?.viewController
                    expect(viewController?.setLocationDelegate).toNot(beNil())
                    expect(viewController?.tokenDetailsDelegate).toNot(beNil())
                    expect(viewController?.switchTabDelegate).toNot(beNil())
                }

                it("config") {
                    let location = Location(path: "config")
                    tokenFlowController?.navigationHandler?(location)
                    let childFlow = tokenFlowController?.childFlow as? ConfigFlowController
                    expect(childFlow).toNot(beNil())
                    expect(childFlow?.delegate).toNot(beNil())
                }
                context("SetLocationDelegate") {
                    it("didTapChangeLocation") {
                        tokenFlowController?.didTapChangeLocation()
                        let childFlow = tokenFlowController?.setLocationFlowController
                        expect(childFlow).toNot(beNil())
                        expect(childFlow?.preferences).toNot(beNil())
                    }
                }

                context("TokenDetailsDelegate") {
                    it("showTokenDetails") {

                        let body = BodyObject()
                        tokenFlowController?.showTokenDetails(model: body)
                        let childFlow = tokenFlowController?.childFlow as? TokenDetailsFlowController
                        expect(childFlow).toNot(beNil())
                    }
                }
            }
        }
    }
}
