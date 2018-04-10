//
//  SettingsFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 08/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Compass

class SettingsFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var childFlow: FlowController?
    internal var storyboard = UIStoryboard.mainStoryboard()!
    internal var viewController: SettingsViewController?
    internal var setLocationFlowController: SetLocationFlowController?

    weak var delegate: AuthUIPresenterFlow?

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
    }

    func start() {
        viewController = SettingsViewController.instantiateFromStoryboard(storyboard)
        viewController?.setLocationDelegate = self
        viewController?.authUIDelegate = self.delegate
        configure.navigationController?.setViewControllers([viewController!], animated: true)
    }

    func defaultFlow(location: Location) {
        self.childFlow?.navigationHandler?(location)
    }
}

extension SettingsFlowController: SetLocationDelegate {
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
