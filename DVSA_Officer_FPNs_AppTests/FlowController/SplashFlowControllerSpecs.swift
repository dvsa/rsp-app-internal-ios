//
//  SplashFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/11/2017.
//  Copyright © 2017 BJSS. All rights reserved.
//

import Quick
import Nimble
import Compass

@testable import DVSA_Officer_FPNs_App

class SplashFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("SplashFlowController") {

            let navigationController = UINavigationController()
            let flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)
            var presenterFlowMock: AuthUIPresenterFlowMock?
            var splashFlowController: SplashFlowController?

            beforeEach {
                AuthUIObservableManagerInjectableMap.set(AuthUIObserverManagerGetterMock())
                splashFlowController = SplashFlowController(configure: flowConfigure)
                presenterFlowMock = AuthUIPresenterFlowMock()
                splashFlowController?.delegate = presenterFlowMock
            }

            context("init") {
                it("should attachObserver") {
                    let authUIObservable = splashFlowController?.authUIObservable.get() as? AuthUIObserverManagerMock
                    expect(authUIObservable?.done["attachObserver"]).to(beTrue())
                }

                it("should not be nil") {
                    expect(splashFlowController).toNot(beNil())
                }

                it("should set configure as main") {
                    expect(splashFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("deinit") {
                it("should removeObserver") {
                    let authUIObservable = splashFlowController?.authUIObservable.get() as? AuthUIObserverManagerMock
                    splashFlowController = nil
                    expect(authUIObservable?.done["removeObserver"]).to(beTrue())
                }
            }

            context("when start") {

                beforeEach {
                    splashFlowController?.start()
                }

                it("should not set window") {
                    expect(splashFlowController?.configure.window).to(beNil())
                }

                it("should set navigation") {
                    expect(splashFlowController?.configure.navigationController).toNot(beNil())
                }

                it("should set authUIPresenter delegate") {
                    expect(splashFlowController?.delegate).toNot(beNil())
                }

            }

            context("navigationHandler") {

                it("should route config") {
                    let location = Location(path: "config", arguments: [:], payload: nil)
                    splashFlowController?.navigationHandler?(location)
                }
            }

            context("AuthUIObserver") {

                var childAuthenticatedFlowMock: FlowControllerMock?

                context("onSignIn") {

                    beforeEach {
                        childAuthenticatedFlowMock = FlowControllerMock(configure: flowConfigure)
                        splashFlowController?.childAuthenticatedFlow = childAuthenticatedFlowMock
                    }

                    it("on success") {
                        splashFlowController?.onSignIn(success: true)
                        expect(childAuthenticatedFlowMock?.done["start"]).toEventually(beTrue())
                    }

                    it("on fail") {
                        splashFlowController?.onSignIn(success: false)
                        expect(childAuthenticatedFlowMock?.done["start"]).toEventually(beFalse())
                    }

                    afterEach {
                        AuthUIObservableManagerInjectableMap.reset()
                    }
                }

                context("onSignOut") {

                    it("on success") {
                        splashFlowController?.onSignOut(success: true)
                        expect(presenterFlowMock?.done["logout"]).toEventually(beFalse())
                    }

                    it("on fail") {
                        splashFlowController?.onSignOut(success: false)
                        expect(presenterFlowMock?.done["logout"]).toEventually(beFalse())
                    }

                }

                context("onRefreshToken") {

                    it("on success") {
                        splashFlowController?.onRefreshToken(success: true)
                        expect(presenterFlowMock?.done["login"]).toEventually(beFalse())
                    }

                    it("on fail") {
                        splashFlowController?.onRefreshToken(success: false)
                        expect(presenterFlowMock?.done["login"]).toEventually(beTrue())
                    }
                }
            }

            context("AuthUIObserver") {

                var childAuthenticatedFlowMock: FlowControllerMock?

                context("onSignIn") {

                    beforeEach {
                        childAuthenticatedFlowMock = FlowControllerMock(configure: flowConfigure)
                        splashFlowController?.childAuthenticatedFlow = childAuthenticatedFlowMock
                    }

                    it("on success") {
                        splashFlowController?.onSignIn(success: true)
                        expect(childAuthenticatedFlowMock?.done["start"]).toEventually(beTrue())
                    }

                    it("on fail") {
                        splashFlowController?.onSignIn(success: false)
                        expect(childAuthenticatedFlowMock?.done["start"]).toEventually(beFalse())
                    }
                }

                context("onSignOut") {

                    it("on success") {
                        splashFlowController?.onSignOut(success: true)
                        expect(presenterFlowMock?.done["logout"]).toEventually(beFalse())
                    }

                    it("on fail") {
                        splashFlowController?.onSignOut(success: false)
                        expect(presenterFlowMock?.done["logout"]).toEventually(beFalse())
                    }

                }

                context("onRefreshToken") {

                    it("on success") {
                        splashFlowController?.onRefreshToken(success: true)
                        expect(presenterFlowMock?.done["login"]).toEventually(beFalse())
                    }

                    it("on fail") {
                        splashFlowController?.onRefreshToken(success: false)
                        expect(presenterFlowMock?.done["login"]).toEventually(beTrue())
                    }
                }
            }

            afterEach {
                AuthUIObservableManagerInjectableMap.reset()
            }
        }
    }
}
