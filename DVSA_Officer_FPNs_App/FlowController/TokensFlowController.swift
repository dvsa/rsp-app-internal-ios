//
//  TokensFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import Compass
import RealmSwift

class TokensFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var childFlow: FlowController?
    internal var viewController: TokensViewController?
    internal var storyboard = UIStoryboard.mainStoryboard()!
    internal var setLocationFlowController: SetLocationFlowController?

    weak var delegate: AuthUIPresenterFlow?

    required init(configure: FlowConfigurable) {
        self.configure = configure
    }

    func start() {
        viewController = TokensViewController.instantiateFromStoryboard(storyboard)
        viewController?.setLocationDelegate = self
        viewController?.tokenDetailsDelegate = self
        viewController?.switchTabDelegate = self
        configure.navigationController?.setViewControllers([viewController!], animated: true)
    }

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

        switch location.route() {
        case .config:
            self.startConfigFlowController()
        default:
            break
        }
    }

    internal func startConfigFlowController() {
        let configure = FlowConfigure(window: nil, navigationController: self.configure.navigationController, parent: self)
        let configChildFlow = ConfigFlowController(configure: configure)
        configChildFlow.delegate = self.delegate
        childFlow = configChildFlow
        childFlow?.start()
    }
}

extension TokensFlowController: SetLocationDelegate {
    func didConfirmLocation(site: SiteObject?, mobileAddress: String?) {
        self.viewController?.updateUI()
    }

    func didTapChangeLocation() {
        let configuration =  FlowConfigure(window: nil, navigationController: self.configure.navigationController, parent: self)
        setLocationFlowController = SetLocationFlowController(configure: configuration)
        setLocationFlowController?.preferences = PreferencesDataSource.shared
        setLocationFlowController?.start()
    }
}

extension TokensFlowController: TokenDetailsDelegate {
    func showTokenDetails(model: BodyObject) {
        let configuration =  FlowConfigure(window: nil, navigationController: self.configure.navigationController, parent: self)
        let tokenDetalilsFlowController = TokenDetailsFlowController(configure: configuration)
        tokenDetalilsFlowController.viewModel = TokenDetailsViewModel(model: model)
        childFlow = tokenDetalilsFlowController
        childFlow?.start()
    }
}

extension TokensFlowController: SwitchTabDelegate {
    func switchToRoute(route: Route) {
        Navigator.handle?(Location(path: route.rawValue))
    }
}
