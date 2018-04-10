//
//  NotificationsFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 08/01/2018.
//  Copyright © 2018 Andrea Scuderi. All rights reserved.
//

import Foundation
import Compass

class NotificationsFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var childFlow: FlowController?
    internal var storyboard = UIStoryboard.mainStoryboard()!
    internal var viewController: NotificationsViewController?

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
    }

    func start() {
        viewController = NotificationsViewController.instantiateFromStoryboard(storyboard)
        viewController?.setLocationDelegate = self
        configure.navigationController?.setViewControllers([viewController!], animated: true)
    }

    func defaultFlow(location: Location) {
        self.childFlow?.navigationHandler?(location)
    }
}

extension NotificationsFlowController: SetLocationDelegate {
    func didConfirmLocation(site: SiteObject?, mobileAddress: String?) {
        self.viewController?.updateUI()
    }

    func didTapChangeLocation() {
        let configuration =  FlowConfigure(window: nil, navigationController: self.configure.navigationController, parent: self)
        let setLocationFlowController = SetLocationFlowController(configure: configuration)
        setLocationFlowController.preferences = PreferencesDataSource.shared
        setLocationFlowController.start()
    }
}
