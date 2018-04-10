//
//  AuthUIObserver.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 01/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

protocol AuthUIObserver: class {
    func name() -> String
    func onSignIn(success: Bool)
    func onSignOut(success: Bool)
    func onRefreshToken(success: Bool)
}

protocol AuthUIObservableManagerProtocol: AuthUIObserver {
    func attachObserver(observer: AuthUIObserver)
    func removeObserver(observer: AuthUIObserver)
    func removeAllObserver()
}

class AuthUIObservableManager: AuthUIObservableManagerProtocol {

    static let shared = AuthUIObservableManager()

    private var observerArray = NSMapTable<NSString, AnyObject>(keyOptions: [.strongMemory], valueOptions: [.weakMemory])

    func name() -> String {
        return "AuthUIObservervable"
    }

    func attachObserver(observer: AuthUIObserver) {
        observerArray.setObject(observer, forKey: observer.name() as NSString)
    }

    func onSignIn(success: Bool) {

        guard let enumerator = observerArray.objectEnumerator() else { return }
        for observer in enumerator {
            if let observer = observer as? AuthUIObserver {
                observer.onSignIn(success: success)
            }
        }
    }

    func onSignOut(success: Bool) {
        guard let enumerator = observerArray.objectEnumerator() else { return }
        for observer in enumerator {
            if let observer = observer as? AuthUIObserver {
                observer.onSignOut(success: success)
            }
        }
    }

    func onRefreshToken(success: Bool) {
        guard let enumerator = observerArray.objectEnumerator() else { return }
        for observer in enumerator {
            if let observer = observer as? AuthUIObserver {
                observer.onRefreshToken(success: success)
            }
        }
    }

    func removeObserver(observer: AuthUIObserver) {
        observerArray.removeObject(forKey: observer.name() as NSString)
    }

    func removeAllObserver() {
        observerArray = NSMapTable<NSString, AnyObject>(keyOptions: [.strongMemory], valueOptions: [.weakMemory])
    }
}

// MARK: Cake Pattern

protocol AuthUIObservableManagerGetterProtocol {
    func get() -> AuthUIObservableManagerProtocol
}

struct AuthUIObservableManagerGetterDefault: AuthUIObservableManagerGetterProtocol {
    func get() -> AuthUIObservableManagerProtocol {
        return AuthUIObservableManager.shared
    }
}

protocol AuthUIObservableManagerGetterInjectable {
    var authUIObservable: AuthUIObservableManagerGetterProtocol { get }
}

extension AuthUIObservableManagerGetterInjectable {
    var authUIObservable: AuthUIObservableManagerGetterProtocol {
        return AuthUIObservableManagerInjectableMap.resolve()
    }
}

public class AuthUIObservableManagerInjectableMap {

    private static  var  mapper: AuthUIObservableManagerGetterProtocol = AuthUIObservableManagerGetterDefault()

    static func resolve() -> AuthUIObservableManagerGetterProtocol {
        return mapper
    }

    static func set(_ mapper: AuthUIObservableManagerGetterProtocol) {
        self.mapper = mapper
    }

    static func reset() {
        self.mapper = AuthUIObservableManagerGetterDefault()
    }

}
