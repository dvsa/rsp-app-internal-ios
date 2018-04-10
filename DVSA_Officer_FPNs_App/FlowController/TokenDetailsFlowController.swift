//
//  TokenDetailsFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Compass
import SVProgressHUD

class TokenDetailsFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var storyboard = UIStoryboard.mainStoryboard()!
    internal var viewController: TokenDetailsViewController?
    internal var notificationViewController: SendNotificationViewController?
    internal let navigationController = UINavigationController()
    internal var alertController: UIAlertController?

    let alertMessage = "Are you sure you want to cancel this payment code?"
    let alertTitle = "Cancel payment code"
    let cancelActionTitle = "Back"
    let okActionTitle = "Yes"

    let alertMessageError = "Unable to cancel payment code."
    let alertTitleError = "Cancel payment code"
    let cancelActionTitleError = "OK"

    var viewModel: TokenDetailsViewModel?

    var syncManager: SynchronizationDelegate = SynchronizationManager.shared

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
    }

    func start() {
        viewController = TokenDetailsViewController.instantiateFromStoryboard(storyboard)
        viewController?.viewModel = viewModel
        viewController?.newTokenDelegate = self
        if let viewController = viewController {
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            configure.navigationController?.topViewController?.navigationItem.backBarButtonItem = backButton
            configure.navigationController?.pushViewController(viewController, animated: true)
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
        navigationController.setViewControllers([notificationViewController], animated: false)

        let selector = #selector(TokenDetailsFlowController.didTapDone)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: selector)
        notificationViewController.navigationItem.rightBarButtonItem = doneButton

        notificationViewController.viewModel = driverViewModel
        configure.navigationController?.present(navigationController, animated: true, completion: nil)
    }

    @objc func didTapDone() {
        configure.navigationController?.dismiss(animated: true) {
            self.notificationViewController = nil
        }
    }

    func revokeToken() {

        SVProgressHUD.show()
        guard let item = viewModel?.model.awsModel() else {
            log.warning("")
            return
        }
        syncManager.delete(item: item) { [weak self] succeded in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if succeded {
                    log.info("Payment code Revoked")
                    self?.viewController?.viewModel?.setDisabled()
                    self?.viewController?.updateUI()
                } else {
                    self?.showCancelError()
                }
            }
        }
    }

    func showCancelError() {
        log.error("Unable to cancel payment code")
        self.alertController = UIAlertController(title: self.alertTitleError, message: self.alertMessageError, preferredStyle: .alert)
        guard let alertController = self.alertController else {
            return
        }
        alertController.view.tintColor = UIColor.dvsaGreen
        let cancelAction = UIAlertAction(title: self.cancelActionTitleError, style: .cancel) { (_) in

        }

        alertController.addAction(cancelAction)
        configure.navigationController?.present(alertController, animated: true) {
        }
    }
}

extension TokenDetailsFlowController: SendNotificationDelegate {
    func didSendNotification() {
        didTapDone()
    }
}

extension TokenDetailsFlowController: NewTokenDetailsDelegate {

    func didTapSendSMS() {
        self.showNotificationViewController(type: .sms)
    }

    func didTapSendEmail() {
        self.showNotificationViewController(type: .email)
    }

    func didTapRevokeToken() {
        alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        guard let alertController = alertController else {
            return
        }
        alertController.view.tintColor = UIColor.dvsaGreen

        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel) { (_) in

        }

        let okAction = UIAlertAction(title: okActionTitle, style: .default) { (_) in
            self.revokeToken()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        configure.navigationController?.present(alertController, animated: true) {
        }
    }
}
