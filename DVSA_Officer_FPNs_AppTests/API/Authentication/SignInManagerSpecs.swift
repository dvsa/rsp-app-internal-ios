//
//  SignInManagerSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/11/2017.
//  Copyright © 2017 BJSS. All rights reserved.
//

import Quick
import Nimble
import Foundation

@testable import DVSA_Officer_FPNs_App

class SignInManagerMock: SignInManagerProtocol {

    var done = TestDone()

    var signInToken: SignInToken = .none
    var isLoggedIn = true
    var isLoggedOut = true

    func isLoggedIn(completion: @escaping (Bool, SignInToken) -> Void) {
        done["isLoggedIn"] = true
        completion(isLoggedIn, signInToken)
    }

    func login(completion: @escaping (Bool, SignInToken) -> Void) {
        done["login"] = true
        completion(isLoggedIn, signInToken)
    }

    func logout(completion: @escaping (Bool) -> Void) {
        done["logout"] = true
        completion(isLoggedOut)
    }
}

class SignInManagerGetterInjectableMock: SignInManagerGetterInjectable {

}

struct SignInManagerGetterMock: SignInManagerGetterProtocol {

    internal var mock = SignInManagerMock()

    func get() -> SignInManagerProtocol {
        return mock
    }
}

class SignInManagerSpecs: QuickSpec {
    override func spec() {

        describe("SignInManagerGetterDefault") {
            it("gets ADALSignInManager") {
                let signInManager = SignInManagerGetterDefault().get() as? CognitoSignInManager
                expect(signInManager).toNot(beNil())
            }
        }

        describe("SignInManagerGetterInjectable") {
            it("gets SignInManagerGetterDefault") {
                let signInManagerGetterInjectableMock = SignInManagerGetterInjectableMock()
                let getterDefault = signInManagerGetterInjectableMock.signInManager as? SignInManagerGetterDefault
                expect(getterDefault).toNot(beNil())
            }

            context("on injection") {

                let objectMock = SignInManagerGetterInjectableMock()

                beforeEach {
                    SignInManagerInjectableMap.set(SignInManagerGetterMock())
                }

                it("don't get Default Mock") {
                    let getterDefault = objectMock.signInManager as? SignInManagerGetterDefault
                    expect(getterDefault).to(beNil())
                }

                it("get Injected Mock") {
                    let getterMock = objectMock.signInManager as? SignInManagerGetterMock
                    expect(getterMock).toNot(beNil())
                }

                afterEach {
                    SignInManagerInjectableMap.reset()
                }
            }
        }

        describe("SignInManagerInjectableMap") {
            it("resolve should return SignInManagerGetterDefault") {
                let getterDefault = SignInManagerInjectableMap.resolve() as? SignInManagerGetterDefault
                expect(getterDefault).toNot(beNil())
            }

            it("set and reset should change and restore resolve behaviour") {

                SignInManagerInjectableMap.set(SignInManagerGetterMock())

                let getterDefault = SignInManagerInjectableMap.resolve() as? SignInManagerGetterDefault
                expect(getterDefault).to(beNil())
                let signInManagerGetterInjectableMock = SignInManagerGetterInjectableMock()
                let getterMock = signInManagerGetterInjectableMock.signInManager as? SignInManagerGetterMock
                expect(getterMock).toNot(beNil())

                SignInManagerInjectableMap.reset()

                let getterDefault2 = SignInManagerInjectableMap.resolve() as? SignInManagerGetterDefault
                expect(getterDefault2).toNot(beNil())
                let getterMock2 = signInManagerGetterInjectableMock.signInManager as? SignInManagerGetterMock
                expect(getterMock2).to(beNil())

            }
        }
    }
}
