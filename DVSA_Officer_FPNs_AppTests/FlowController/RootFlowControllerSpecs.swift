//
//  RootFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 12/09/2017.
//

import Quick
import Nimble
import UIKit
import Compass
@testable import DVSA_Officer_FPNs_App

class FlowControllerMock: FlowController {

    var done = TestDone()

    required init(configure: FlowConfigurable) {

    }

    func start() {
        done["start"] = true
    }

    lazy var navigationHandler: ((Location) -> Void)? = { [weak self] _ in
        self?.done["navigationHandler"] = true
        return
    }
}

class AuthUIPresenterFlowMock: AuthUIPresenterFlow {

    var done = TestDone()

    func login() {
        done["login"] = true
    }

    func logout() {
        done["logout"] = true
    }

    func defaultFlow(location: Location) {
        done["defaultFlow"] = true
    }

    func isLoggedIn(completion: @escaping (Bool) -> Void) {
        completion(false)
    }

}

class RootFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {

        var mainFlowController: RootFlowController?

        beforeEach {
            AuthUIObservableManagerInjectableMap.set(AuthUIObserverManagerGetterMock())
            SignInManagerInjectableMap.set(SignInManagerGetterMock())
        }

        describe("RootFlowController") {

            let window = UIWindow()
            let configure = FlowConfigure(window: window, navigationController: nil, parent: nil)
            var preferencesMock: PreferencesDataSourceMock!
            var synchmanagerMock: SynchronizationManagerMock!

            beforeEach {
                preferencesMock = PreferencesDataSourceMock()
                synchmanagerMock = SynchronizationManagerMock()
                mainFlowController = RootFlowController(configure: configure)
                mainFlowController?.preferences = preferencesMock
                mainFlowController?.synchmanager = synchmanagerMock
            }

            context("when loaded") {
                it("should not be nil") {

                    expect(mainFlowController).toNot(beNil())
                }

                it("should set configure as main") {
                    expect(mainFlowController?.configure.whichFlowAmI()).to(equal(.main))
                }

                it("should have signInManager") {
                    expect(mainFlowController?.signInManager).toNot(beNil())
                }
            }

            context("when start") {

                beforeEach {
                    mainFlowController?.start()
                }

                it("should set window") {
                    expect(mainFlowController?.configure.window?.rootViewController).toNot(beNil())
                    expect(mainFlowController?.configure.window?.isKeyWindow).to(beTrue())
                }

                it("should not set navigation") {
                    expect(mainFlowController?.configure.navigationController).to(beNil())
                }

                describe("childflow") {

                    it("should exists") {
                        let childFlow = mainFlowController?.childFlow
                        expect(childFlow).toNot(beNil())
                    }

                    it("should set delegate") {
                        let childFlow = mainFlowController?.childFlow
                        let sampleAppFlow = childFlow as? TabFlowController
                        expect(sampleAppFlow).toNot(beNil())
                        expect(sampleAppFlow?.delegate).toNot(beNil())
                    }
                }

                describe("splashChildFlow") {

                    it("should exists") {
                       let splashChildFlow = mainFlowController?.splashChildFlow
                        expect(splashChildFlow).toNot(beNil())
                    }

                    it("should set delegate") {
                        let splashChildFlow = mainFlowController?.splashChildFlow
                        let sampleAppFlow = splashChildFlow as? SplashFlowController
                        expect(sampleAppFlow).toNot(beNil())
                        expect(sampleAppFlow?.delegate).toNot(beNil())
                    }
                }

                it("should set authUIPresenter") {
                    expect(mainFlowController?.authUIPresenter).toNot(beNil())
                }

            }

            context("when start") {

                var authPresenterMock: AuthUIPresenterFlowMock?

                beforeEach {
                    authPresenterMock = AuthUIPresenterFlowMock()
                    mainFlowController?.authUIPresenter = authPresenterMock!
                    mainFlowController?.start()
                }

                it("should not call login") {
                    expect(authPresenterMock?.done["login"]).toEventually(beFalse())
                }

                it("should not call logout") {
                    expect(authPresenterMock?.done["logout"]).toEventually(beFalse())
                }

                afterEach {
                    mainFlowController?.authUIPresenter = mainFlowController!
                }

            }

            context("navigationHandler") {

                var authPresenterMock: AuthUIPresenterFlowMock?
                var signInManagerMock: SignInManagerMock?
                var authUIObserverManagerMock: AuthUIObserverManagerMock?

                describe("authUIPresenter") {
                    beforeEach {
                        authPresenterMock = AuthUIPresenterFlowMock()
                        mainFlowController?.authUIPresenter = authPresenterMock!
                        signInManagerMock = mainFlowController?.signInManager.get() as? SignInManagerMock
                    }

                    it("should route login") {
                        let location = Location(path: "login", arguments: [:], payload: nil)
                        mainFlowController?.navigationHandler?(location)
                        expect(authPresenterMock?.done["login"]).toEventually(beTrue())
                    }

                    it("should route logout") {
                        let location = Location(path: "logout", arguments: [:], payload: nil)
                        mainFlowController?.navigationHandler?(location)
                        expect(authPresenterMock?.done["logout"]).toEventually(beTrue())
                    }

                    it("should route unknown") {
                        let location = Location(path: "something", arguments: [:], payload: nil)
                        mainFlowController?.navigationHandler?(location)
                        expect(authPresenterMock?.done["logout"]).toEventually(beFalse())
                        expect(authPresenterMock?.done["login"]).toEventually(beFalse())
                    }

                    it("should route a valid Route") {
                        let location = Location(path: Route.config.rawValue, arguments: [:], payload: nil)
                        mainFlowController?.navigationHandler?(location)
                        expect(authPresenterMock?.done["defaultFlow"]).toEventually(beTrue())
                    }
                }

                describe("signInManager") {

                    beforeEach {
                        mainFlowController?.authUIPresenter = mainFlowController!
                        signInManagerMock = mainFlowController?.signInManager.get() as? SignInManagerMock
                        authUIObserverManagerMock = mainFlowController?.authUIObservable.get() as? AuthUIObserverManagerMock
                        signInManagerMock?.signInToken = .cognito
                        mainFlowController?.start()
                    }

                    it("should route login") {
                        let location = Location(path: "login", arguments: [:], payload: nil)
                        mainFlowController?.navigationHandler?(location)
                        expect(signInManagerMock?.done["login"]).toEventually(beTrue())
                        expect(authUIObserverManagerMock?.done["onSignIn"]).toEventually(beTrue())
                        expect(preferencesMock?.done["subscribeUserPreferences"]).toEventually(beTrue())
                        expect(preferencesMock?.done["isFirstLogin"]).toEventually(beTrue())
                        expect(synchmanagerMock.done["sites"]).toEventually(beTrue())
                    }

                    it("should route logout") {
                        let location = Location(path: "logout", arguments: [:], payload: nil)
                        mainFlowController?.navigationHandler?(location)
                        expect(preferencesMock?.done["unsubscribeUserPreferences"]).toEventually(beTrue())
                        expect(signInManagerMock?.done["logout"]).toEventually(beTrue())
                        expect(authUIObserverManagerMock?.done["onSignOut"]).toEventually(beTrue())
                        expect(preferencesMock?.done["clean"]).toEventually(beTrue())
                    }

                    it("isLoggedIn should update preferences") {

                        mainFlowController?.isLoggedIn { (_) in

                        }
                        expect(authUIObserverManagerMock?.done["onRefreshToken"]).toEventually(beTrue())
                        expect(preferencesMock?.done["subscribeUserPreferences"]).toEventually(beTrue())
                        expect(preferencesMock?.done["isFirstLogin"]).toEventually(beFalse())
                        expect(synchmanagerMock.done["sites"]).toEventually(beTrue())
                    }
                }

                describe("signInManager fail to login") {

                    beforeEach {
                        mainFlowController?.authUIPresenter = mainFlowController!
                        signInManagerMock = mainFlowController?.signInManager.get() as? SignInManagerMock
                        authUIObserverManagerMock = mainFlowController?.authUIObservable.get() as? AuthUIObserverManagerMock
                        signInManagerMock?.signInToken = .cognito
                        signInManagerMock?.isLoggedIn = false
                        mainFlowController?.start()
                    }

                    it("should not call authenticated request") {
                        let location = Location(path: "login", arguments: [:], payload: nil)
                        mainFlowController?.navigationHandler?(location)
                        expect(signInManagerMock?.done["login"]).toEventually(beTrue())
                        expect(authUIObserverManagerMock?.done["onSignIn"]).toEventually(beTrue())
                        expect(preferencesMock?.done["subscribeUserPreferences"]).toEventually(beFalse())
                        expect(preferencesMock?.done["isFirstLogin"]).toEventually(beFalse())
                        expect(synchmanagerMock.done["sites"]).toEventually(beFalse())
                    }

                    it("isLoggedIn should not update preferences") {

                        mainFlowController?.isLoggedIn { (_) in

                        }
                        expect(authUIObserverManagerMock?.done["onRefreshToken"]).toEventually(beTrue())
                        expect(preferencesMock?.done["subscribeUserPreferences"]).toEventually(beFalse())
                        expect(preferencesMock?.done["isFirstLogin"]).toEventually(beFalse())
                        expect(synchmanagerMock.done["sites"]).toEventually(beFalse())
                    }
                }
            }
        }

        afterEach {
            AuthUIObservableManagerInjectableMap.reset()
            SignInManagerInjectableMap.reset()
        }
    }
}
