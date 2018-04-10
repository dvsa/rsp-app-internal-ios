//
//  RootFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import Compass
import AWSAuthUI
import ADAL
import SVProgressHUD

protocol AuthUIPresenterFlow: class, Flow {
    func login()
    func logout()
    func isLoggedIn(completion: @escaping (Bool) -> Void)
}

class RootFlowController: FlowController, SignInManagerGetterInjectable, AuthUIObservableManagerGetterInjectable {

    internal let configure: FlowConfigurable
    internal var childFlow: FlowController?
    internal var splashChildFlow: FlowController?

    var preferences: PreferencesDataSourceProtocol = PreferencesDataSource.shared
    var synchmanager: SynchronizationDelegate = SynchronizationManager.shared

    lazy var authUIPresenter: AuthUIPresenterFlow = {
        return self
    }()

    lazy var navigationHandler: ((Location) -> Void)? = { [weak self] (location) in

        switch location.route() {
        case .login:
            self?.authUIPresenter.login()
        case .logout:
            self?.authUIPresenter.logout()
        case .newToken:
            self?.childFlow?.navigationHandler?(location)
        case .unknown:
            break
        default:
            self?.authUIPresenter.defaultFlow(location: location)
        }
    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(forceLogout(_:)),
                                               name: NSNotification.Name.AD_ERROR_SERVER_USER_INPUT_NEEDED_NOTIFICATION,
                                               object: nil)
    }

    deinit {
        self.authUIObservable.get().removeAllObserver()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AD_ERROR_SERVER_USER_INPUT_NEEDED_NOTIFICATION, object: nil)
    }

    func start() {

        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let storyboardNC = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as? UINavigationController
        let navigationController = storyboardNC ?? UINavigationController()
        if let frame = configure.window?.bounds {
            navigationController.view.frame = frame
        }
        navigationController.setNavigationBarHidden(true, animated: false)

        configure.window?.rootViewController = navigationController
        configure.window?.makeKeyAndVisible()

        let rootAppConf = FlowConfigure(window: nil, navigationController: navigationController, parent: self)

        let configChildFlow = TabFlowController(configure: rootAppConf)
        configChildFlow.delegate = self
        childFlow = configChildFlow

        let args = ProcessInfo.processInfo.arguments
        if args.contains("UI_TEST_MODE") {
            try? Navigator.navigate(location: Location(path: "logout"))
        }

        let splashFlowController = SplashFlowController(configure: rootAppConf)
        splashFlowController.delegate = self
        splashFlowController.childAuthenticatedFlow = configChildFlow
        splashChildFlow = splashFlowController
        splashFlowController.start()

        if args.contains("UI_TEST_MODE"),
            let route = ProcessInfo.processInfo.environment["route"] {
            try? Navigator.navigate(location: Location(path: route))
        }
    }

    @objc func forceLogout (_ notification: NSNotification) {
        log.severe("forceLogout")
        DispatchQueue.main.async {
            self.logout()
            SVProgressHUD.setBackgroundColor(.lightGray)
            SVProgressHUD.showError(withStatus: "Session Exprired")
        }
    }
}

extension RootFlowController: AuthUIPresenterFlow {

    func isLoggedIn(completion: @escaping (Bool) -> Void) {

        self.signInManager.get().isLoggedIn { [weak self] (isLoggedIn, signInToken) in
            log.info(signInToken)
            switch signInToken {
            case .none:
                break
            case .adal(let token):
                let username = token.userInformation?.userId ?? ""
                log.debug(username)
            case .token(let token):
                log.debug(token)
            case .cognito:
                if isLoggedIn {
                    self?.preferences.subscribeUserPreferences(isFirstLogin: false)
                    self?.synchmanager.sites { succeded in
                        if succeded {
                            log.info("sync sites succeded")
                        } else {
                            log.error("sync sites failed")
                        }
                    }
                }
            }
            completion(isLoggedIn)
            DispatchQueue.main.async { [weak self] in
                self?.authUIObservable.get().onRefreshToken(success: isLoggedIn)
            }
        }
    }

    func login() {

        self.signInManager.get().login { [weak self] (isLoggedIn, signInToken) in
            log.info(signInToken)
            switch signInToken {
            case .none:
                break
            case .adal(let token):
                let username = token.userInformation?.userId ?? ""
                log.debug(username)
            case .token(let token):
                log.debug(token)
            case .cognito:
                if isLoggedIn {
                    self?.preferences.subscribeUserPreferences(isFirstLogin: true)
                    self?.synchmanager.sites { succeded in
                        if succeded {
                            log.info("sync sites succeded")
                        } else {
                            log.error("sync sites failed")
                        }
                    }
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.authUIObservable.get().onSignIn(success: isLoggedIn)
            }
        }
    }

    func logout() {

        self.preferences.unsubscribeUserPreferences {
            self.signInManager.get().logout { (_) in
                DispatchQueue.main.async { [weak self] in
                    if self?.preferences.clean() ?? false {
                        log.info("Preference cleaned")
                    } else {
                        log.error("Preference clean error")
                    }
                    guard let rootNavigationController = self?.configure.window?.rootViewController as? UINavigationController else { return }
                    rootNavigationController.popToRootViewController(animated: false)
                    self?.authUIObservable.get().onSignOut(success: true)
                    self?.splashChildFlow?.start()
                }
            }
        }
    }

    func defaultFlow(location: Location) {
        self.splashChildFlow?.navigationHandler?(location)
    }
}
