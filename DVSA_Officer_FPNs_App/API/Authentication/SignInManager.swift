//
//  SignInManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 31/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import ADAL

enum SignInToken {
    case none
    case adal(ADTokenCacheItem)
    case token(String)
    case cognito
}

protocol SignInManagerProtocol: class {
    func isLoggedIn(completion: @escaping (Bool, SignInToken) -> Void)
    func login(completion: @escaping (Bool, SignInToken) -> Void)
    func logout(completion: @escaping (Bool) -> Void)
}

// MARK: Cake Pattern

protocol SignInManagerGetterProtocol {
    func get() -> SignInManagerProtocol
}

struct SignInManagerGetterDefault: SignInManagerGetterProtocol {
    func get() -> SignInManagerProtocol {
        //return ADALSignInManager.shared
        return CognitoSignInManager.shared
    }
}

protocol SignInManagerGetterInjectable {
    var signInManager: SignInManagerGetterProtocol { get }
}

extension SignInManagerGetterInjectable {
    var signInManager: SignInManagerGetterProtocol {
        return SignInManagerInjectableMap.resolve()
    }
}

public class SignInManagerInjectableMap {

    private static  var  mapper: SignInManagerGetterProtocol = SignInManagerGetterDefault()

    static func resolve() -> SignInManagerGetterProtocol {
        return mapper
    }

    static func set(_ mapper: SignInManagerGetterProtocol) {
        self.mapper = mapper
    }

    static func reset() {
        self.mapper = SignInManagerGetterDefault()
    }

}
