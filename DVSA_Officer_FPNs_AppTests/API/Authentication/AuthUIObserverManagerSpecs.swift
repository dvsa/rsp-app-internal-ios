//
//  AuthUIObserverManagerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 02/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import Foundation

@testable import DVSA_Officer_FPNs_App

class AuthUIObserverManagerMock: AuthUIObservableManagerProtocol {

    var done = TestDone()

    func attachObserver(observer: AuthUIObserver) {
        done["attachObserver"] = true
    }

    func removeObserver(observer: AuthUIObserver) {
        done["removeObserver"] = true
    }

    func removeAllObserver() {
        done["removeAllObserver"] = true
    }

    func name() -> String {
        return "AuthUIObserverManagerMock"
    }

    func onSignIn(success: Bool) {
        done["onSignIn"] = true
    }

    func onSignOut(success: Bool) {
        done["onSignOut"] = true
    }

    func onRefreshToken(success: Bool) {
        done["onRefreshToken"] = true
    }
}

class AuthUIOManagerGetterInjectableMock: AuthUIObservableManagerGetterInjectable {

}

struct AuthUIObserverManagerGetterMock: AuthUIObservableManagerGetterProtocol {

    internal var mock = AuthUIObserverManagerMock()

    func get() -> AuthUIObservableManagerProtocol {
        return mock
    }
}

class AuthUIObserverManagerSpecs: QuickSpec {
    override func spec() {

        describe("AuthUIObservableManagerGetterDefault") {
            it("gets AuthUIObservableManager") {
                let managerGetter = AuthUIObservableManagerGetterDefault().get() as? AuthUIObservableManager
                expect(managerGetter).toNot(beNil())
            }
        }

        describe("AuthUIObservableManagerGetterInjectable") {
            it("gets AuthUIObservableManagerGetterDefault") {
                let managerGetterInjectableMock = AuthUIOManagerGetterInjectableMock()
                let getterDefault = managerGetterInjectableMock.authUIObservable as? AuthUIObservableManagerGetterDefault
                expect(getterDefault).toNot(beNil())
            }

            context("on injection") {

                let objectMock = AuthUIOManagerGetterInjectableMock()

                beforeEach {
                    AuthUIObservableManagerInjectableMap.set(AuthUIObserverManagerGetterMock())
                }

                it("don't get Default Mock") {
                    let getterDefault = objectMock.authUIObservable as? AuthUIObservableManagerGetterDefault
                    expect(getterDefault).to(beNil())
                }

                it("get Injected Mock") {
                    let getterMock = objectMock.authUIObservable as? AuthUIObserverManagerGetterMock
                    expect(getterMock).toNot(beNil())
                }
                afterEach {
                    AuthUIObservableManagerInjectableMap.reset()
                }
            }
        }

        describe("AuthUIObservableManagerInjectableMap") {
            it("resolve should return AuthUIObservableManagerGetterDefault") {
                let getterDefault = AuthUIObservableManagerInjectableMap.resolve() as? AuthUIObservableManagerGetterDefault
                expect(getterDefault).toNot(beNil())
            }

            it("set and reset should change and restore resolve behaviour") {

                AuthUIObservableManagerInjectableMap.set(AuthUIObserverManagerGetterMock())

                let getterDefault = AuthUIObservableManagerInjectableMap.resolve() as? AuthUIObservableManagerGetterDefault
                expect(getterDefault).to(beNil())
                let objectMock = AuthUIOManagerGetterInjectableMock()
                let getterMock = objectMock.authUIObservable as? AuthUIObserverManagerGetterMock
                expect(getterMock).toNot(beNil())

                AuthUIObservableManagerInjectableMap.reset()

                let getterDefault2 = AuthUIObservableManagerInjectableMap.resolve() as? AuthUIObservableManagerGetterDefault
                expect(getterDefault2).toNot(beNil())
                let getterMock2 = objectMock.authUIObservable as? AuthUIObserverManagerGetterMock
                expect(getterMock2).to(beNil())

            }
        }
    }
}
