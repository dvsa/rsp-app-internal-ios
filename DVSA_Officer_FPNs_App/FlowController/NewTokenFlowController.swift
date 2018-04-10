//
//  NewTokenFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 07/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Compass
import RealmSwift
import Whisper

protocol NewTokenDelegate: class {
    func didTapStartOCRSession()
    func didTapCreateToken()
}

protocol CreateTokenDetailsDelegate: class {
    func didTapDone()
}

protocol OCRSessionDelegate: class {
    func didTapCancelOCRSession()
    func didTapDoneOCRSession(model: NewTokenModel?)
}

class NewTokenFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var childFlow: FlowController?
    internal var storyboard = UIStoryboard.mainStoryboard()!
    internal var viewController: NewTokenViewController?
    internal var modalVC: UINavigationController?
    internal var setLocationFlowController: SetLocationFlowController?

    var datasource: ObjectsDataSource
    var notificationToken: NotificationToken?
    var preferences: PreferencesDataSourceProtocol = PreferencesDataSource.shared

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
        self.datasource = PersistentDataSource()
    }

    deinit {
        notificationToken?.invalidate()
    }

    func start() {
        viewController = NewTokenViewController.instantiateFromStoryboard(storyboard)
        viewController?.newTokenDelegate = self
        viewController?.setLocationDelegate = self
        viewController?.viewModel = NewTokenViewModel()

        configure.navigationController?.setViewControllers([viewController!], animated: true)
    }
}

extension NewTokenFlowController: SetLocationDelegate {
    func didConfirmLocation(site: SiteObject?, mobileAddress: String?) {
        self.viewController?.updateUI()
        self.childFlow = nil
    }

    func didTapChangeLocation() {
        let configuration =  FlowConfigure(window: nil, navigationController: self.configure.navigationController, parent: self)
        setLocationFlowController = SetLocationFlowController(configure: configuration)
        setLocationFlowController?.preferences = PreferencesDataSource.shared
        self.childFlow = setLocationFlowController
        self.childFlow?.start()
    }
}

extension NewTokenFlowController: NewTokenDelegate {
    func didTapCreateToken() {

        guard let newTokenModel = viewController?.viewModel.model else {
            return
        }
        do {
            let key = Environment.tokenEncryptionKey
            let childViewModel = try NewTokenDetailsViewModel(model: newTokenModel,
                                                              preferences: preferences,
                                                               datasource: datasource,
                                                               key: key)
            let flowConfig = FlowConfigure(window: nil, navigationController: configure.navigationController, parent: self)
            let flowController = NewTokenDetailsFlowController(configure: flowConfig)
            flowController.viewModel = childViewModel
            flowController.createTokenDelegate = self
            self.childFlow = flowController
            self.childFlow?.start()

        } catch let error {

            guard var localizedError = error as? LocalizedError else {
                log.error(error)
                return
            }
            if !(localizedError is NewTokenDetailsViewModelError) && !(localizedError is DataSourceError) {
                localizedError = NewTokenDetailsViewModelError.realmError
            }

            let announcement = Announcement(title: localizedError.localizedDescription, subtitle: localizedError.failureReason, duration: 5)
            ColorList.Shout.background = UIColor.red
            ColorList.Shout.title = UIColor.white
            ColorList.Shout.subtitle = UIColor.white
            ColorList.Shout.dragIndicator = UIColor.white
            Whisper.show(shout: announcement, to: configure.navigationController!) {
            }
        }
    }

    func didTapStartOCRSession() {
        let newTokenModel = NewTokenModel(value: viewController?.viewModel.model)
        let cameraViewModel = OCRCameraSessionViewModel(model: newTokenModel)
        let cameraVC = OCRCameraSessionViewController.instantiate(delegate: self, viewModel: cameraViewModel)
        let navigationController = UINavigationController()
        navigationController.addChildViewController(cameraVC)
        self.modalVC = navigationController
        configure.navigationController?.present(navigationController, animated: true, completion: nil)
    }
}

extension NewTokenFlowController: CreateTokenDetailsDelegate {
    func didTapDone() {
        //Reset the screen
        viewController?.viewModel = NewTokenViewModel()
    }
}

extension NewTokenFlowController: OCRSessionDelegate {
    func didTapCancelOCRSession() {
        configure.navigationController?.dismiss(animated: true) {
            self.modalVC = nil
        }
    }

    func didTapDoneOCRSession(model: NewTokenModel?) {
        if let unwrappedModel = model {
            viewController?.viewModel.model = unwrappedModel
            viewController?.bindToViewModel(animated: false)
            viewController?.updateUIWithValidation(self)
        }
        configure.navigationController?.dismiss(animated: true) {
            self.modalVC = nil
        }
    }
}
