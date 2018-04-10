//
//  ConfigFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import UIKit
import Compass

class ConfigFlowController: FlowController, AuthUIObservableManagerGetterInjectable {

    internal let configure: FlowConfigurable
    internal let model = ConfigModel()
    internal let viewModel: ListViewModel<ConfigModel>

    weak var delegate: AuthUIPresenterFlow?

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

        switch location.route() {
        case .config:
            self.start()
        default:
            break
            //self.childFlow?.navigationHandler?(location)
        }
    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
        self.viewModel = ListViewModel(model: model)
        self.authUIObservable.get().attachObserver(observer: self)
    }

    deinit {
        self.authUIObservable.get().removeObserver(observer: self)
    }

    func start() {

        let configureTable = ConfigureTable(styleTable: .plain,
                                            title: "Config",
                                            delegate: self,
                                            cellStyle: .subtitle,
                                            reuseIdentifier: "MainViewCell")
        let viewController = ListTableViewController<ConfigModel>(viewModel: viewModel, configure: configureTable) { item, cell in
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.value

            cell.textLabel?.isAccessibilityElement = true
            cell.textLabel?.accessibilityIdentifier = "name"
            cell.detailTextLabel?.isAccessibilityElement = true
            cell.detailTextLabel?.accessibilityIdentifier = "value"
        }
        self.setupRightBarButtonItem(navigationItem: viewController.navigationItem, isLoggedIn: true)
        configure.navigationController?.pushViewController(viewController, animated: true)
    }

    internal func setupRightBarButtonItem(navigationItem: UINavigationItem, isLoggedIn: Bool) {
        let loginButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = loginButton
        navigationItem.rightBarButtonItem?.target = self

        if isLoggedIn {
            navigationItem.rightBarButtonItem?.title = NSLocalizedString("Sign-Out", comment: "Label for the logout button.")
            navigationItem.rightBarButtonItem?.action = #selector(ConfigFlowController.logout)
        }
    }

    @objc func logout() {
        self.delegate?.logout()
    }
}

extension ConfigFlowController: AuthUIObserver {

    func name() -> String {
        return "ConfigFlowController"
    }

    func onSignIn (success: Bool) {
        // handle successful sign in
        if success,
            let navigationItem = configure.navigationController?.topViewController?.navigationItem {
            DispatchQueue.main.async {
                self.setupRightBarButtonItem(navigationItem: navigationItem, isLoggedIn: true)
            }
        } else {
            // handle cancel operation from user
        }
    }

    func onSignOut (success: Bool) {
        // handle successful sign in
        if success,
            let navigationItem = configure.navigationController?.topViewController?.navigationItem {
            DispatchQueue.main.async {
                self.setupRightBarButtonItem(navigationItem: navigationItem, isLoggedIn: false)
            }
        } else {
            // handle cancel operation from user
        }
    }

    func onRefreshToken(success: Bool) {
        if let navigationItem = configure.navigationController?.topViewController?.navigationItem {
            DispatchQueue.main.async {
                self.setupRightBarButtonItem(navigationItem: navigationItem, isLoggedIn: success)
            }
        }
    }
}

extension ConfigFlowController: ListTableViewControllerDelegate {
    func refreshData(completion: @escaping (Bool) -> Void) {

    }

    func didSelect(key: Int) {

    }
}
