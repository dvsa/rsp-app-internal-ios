//
//  SplashFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 31/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import Compass

class SplashFlowController: FlowController, AuthUIObservableManagerGetterInjectable {

    internal let configure: FlowConfigurable
    internal var childAuthenticatedFlow: FlowController?
    internal var location: Location?

    weak var delegate: AuthUIPresenterFlow?

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

        switch location.route() {
        case .config:
            self.delegate?.isLoggedIn { [weak self] isLoggedIn in
                if isLoggedIn {
                    self?.childAuthenticatedFlow?.navigationHandler?(location)
                } else {
                    self?.location = location
                }
            }
        default:
            break
        }
    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
        self.authUIObservable.get().attachObserver(observer: self)
    }

    deinit {
        self.authUIObservable.get().removeObserver(observer: self)
    }

    func start() {
        let storyboard = UIStoryboard.mainStoryboard()!
        let viewController = SplashViewController.instantiateFromStoryboard(storyboard)
        configure.navigationController?.setViewControllers([viewController], animated: false)
        delegate?.isLoggedIn { [weak self] isLoggedIn in
            if isLoggedIn {
                self?.childAuthenticatedFlow?.start()
            }
        }
    }
}

extension SplashFlowController: AuthUIObserver {

    func name() -> String {
        return "SplashFlowController"
    }

    func onSignIn (success: Bool) {

        guard success else { return }
        DispatchQueue.main.async {
            self.childAuthenticatedFlow?.start()
            if  let storedLocation = self.location {
                self.location = nil
                self.navigationHandler?(storedLocation)
            }
        }
    }

    func onSignOut (success: Bool) {

    }

    func onRefreshToken(success: Bool) {
        if !success {
            DispatchQueue.main.async {
                self.delegate?.login()
            }
        }
    }
}
