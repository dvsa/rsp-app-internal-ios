//
//  NewTokenDetailsFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 26/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Compass

protocol NewTokenDetailsDelegate: class {
    func didTapSendSMS()
    func didTapSendEmail()
    func didTapRevokeToken()
}

protocol SendNotificationDelegate: class {
    func didSendNotification()
}

class NewTokenDetailsFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var storyboard = UIStoryboard.mainStoryboard()!
    internal var viewController: NewTokenDetailsViewController?
    internal var notificationViewController: SendNotificationViewController?
    let navigationController = UINavigationController()
    var synchManager: SynchronizationDelegate = SynchronizationManager.shared

    var viewModel: NewTokenDetailsViewModel?
    weak var createTokenDelegate: CreateTokenDetailsDelegate?

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
    }

    func start() {

        viewController = NewTokenDetailsViewController.instantiateFromStoryboard(storyboard)
        viewController?.createTokenDelegate = self
        viewController?.viewModel = viewModel
        viewController?.newTokenDelegate = self
        navigationController.setViewControllers([viewController!], animated: false)
        configure.navigationController?.present(navigationController, animated: true, completion: nil)
        if let viewModel = viewModel {
            try? synchManager.synchronize { (status) in
                viewModel.isSynchronized = status
            }
        }
    }

    internal func showNotificationViewController(type: DriverNotificationType) {
        notificationViewController = SendNotificationViewController.instantiateFromStoryboard(storyboard)
        notificationViewController?.sendNotificationDelegate = self
        guard let notificationViewController = notificationViewController,
            let document = viewModel?.model.value,
            let driverViewModel = DriverNotificationViewModel(document: document, type: type) else {
                return
        }
        notificationViewController.viewModel = driverViewModel
        self.navigationController.pushViewController(notificationViewController, animated: true)
    }
}

extension NewTokenDetailsFlowController: CreateTokenDetailsDelegate {
    func didTapDone() {
        self.createTokenDelegate?.didTapDone()
        configure.navigationController?.dismiss(animated: true) {
            self.notificationViewController = nil
        }
    }
}

extension NewTokenDetailsFlowController: SendNotificationDelegate {
    func didSendNotification() {
        notificationViewController?.navigationController?.popViewController(animated: true)
    }
}

extension NewTokenDetailsFlowController: NewTokenDetailsDelegate {

    func didTapRevokeToken() {

    }

    func didTapSendSMS() {
        self.showNotificationViewController(type: .sms)
    }

    func didTapSendEmail() {
        self.showNotificationViewController(type: .email)
    }
}
