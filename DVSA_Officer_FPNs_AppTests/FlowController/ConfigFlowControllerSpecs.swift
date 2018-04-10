//
//  ConfigFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit
import Compass
@testable import DVSA_Officer_FPNs_App

class ConfigFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {

        beforeEach {
            AuthUIObservableManagerInjectableMap.set(AuthUIObserverManagerGetterMock())
        }

        describe("ConfigFlowController") {

            let navigationController = UINavigationController()
            let flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)
            var flowDelegateMock: AuthUIPresenterFlowMock?
            var configFlowController: ConfigFlowController?

            beforeEach {
                configFlowController = ConfigFlowController(configure: flowConfigure)
                flowDelegateMock = AuthUIPresenterFlowMock()
                configFlowController?.delegate = flowDelegateMock
            }

            context("init") {
                it("should attachObserver") {
                    let authUIObservable = configFlowController?.authUIObservable.get() as? AuthUIObserverManagerMock
                    expect(authUIObservable?.done["attachObserver"]).to(beTrue())
                }

                it("should not be nil") {
                    expect(configFlowController).toNot(beNil())
                }

                it("should set configure as main") {
                    expect(configFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("deinit") {
                it("should removeObserver") {
                    let authUIObservable = configFlowController?.authUIObservable.get() as? AuthUIObserverManagerMock
                    configFlowController = nil
                    expect(authUIObservable?.done["removeObserver"]).to(beTrue())
                }
            }

            context("when start") {

                beforeEach {
                    configFlowController?.start()
                }

                it("should not set window") {
                    expect(configFlowController?.configure.window).to(beNil())
                }

                it("should set navigation") {
                    expect(configFlowController?.configure.navigationController).toNot(beNil())
                }

                it("should set authUIPresenter delegate") {
                    expect(configFlowController?.delegate).toNot(beNil())
                }

            }

            context("navigationHandler") {

                it("should route config") {
                    let location = Location(path: "config", arguments: [:], payload: nil)
                    configFlowController?.navigationHandler?(location)
                }
            }

            context("logout") {

                it("should call logout on delegate") {
                    configFlowController?.logout()
                    expect(flowDelegateMock?.done["logout"]).to(beTrue())
                }
            }

            context("AuthUIObserver") {

                var navigationItem: UINavigationItem?

                beforeEach {
                    let viewController = UIViewController()
                    configFlowController?.configure.navigationController?.setViewControllers([viewController], animated: false)
                    configFlowController?.setupRightBarButtonItem(navigationItem: viewController.navigationItem, isLoggedIn: true)
                    navigationItem = configFlowController?.configure.navigationController?.topViewController?.navigationItem
                }

                context("onSignIn") {

                    it("on success") {
                        configFlowController?.onSignIn(success: true)
                        expect(navigationItem).toNot(beNil())
                        expect(navigationItem?.backBarButtonItem?.title).toEventually(equal("Back"))
                        expect(navigationItem?.rightBarButtonItem?.title).toEventually(equal("Sign-Out"))
                    }
                }

                context("onSignOut") {

                    it("on success") {
                        configFlowController?.onSignOut(success: true)
                        expect(navigationItem).toNot(beNil())
                        expect(navigationItem?.backBarButtonItem?.title).toEventually(equal("Back"))
                        expect(navigationItem?.rightBarButtonItem?.title).toEventually(beNil())
                    }
                }

                context("onRefreshToken") {

                    it("on success") {
                        configFlowController?.onRefreshToken(success: true)
                        expect(navigationItem).toNot(beNil())
                        expect(navigationItem?.backBarButtonItem?.title).toEventually(equal("Back"))
                        expect(navigationItem?.rightBarButtonItem?.title).toEventually(equal("Sign-Out"))
                    }

                    it("on fail") {
                        configFlowController?.onRefreshToken(success: false)
                        expect(navigationItem).toNot(beNil())
                        expect(navigationItem?.backBarButtonItem?.title).toEventually(equal("Back"))
                        expect(navigationItem?.rightBarButtonItem?.title).toEventually(beNil())
                    }

                }
            }
        }

        afterEach {
            AuthUIObservableManagerInjectableMap.reset()
        }
    }
}
