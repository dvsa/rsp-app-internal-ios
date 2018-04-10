//
//  TabFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Compass

protocol SwitchTabDelegate: class {
    func switchToRoute(route: Route)
}

class TabFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var childFlows: [String: FlowController] = [:]
    internal var childNavControllers: [String: UINavigationController] = [:]
    internal var storyboard: UIStoryboard! = UIStoryboard.mainStoryboard()

    internal var preferences: PreferencesDataSourceProtocol = PreferencesDataSource.shared
    internal var setLocationFlowController: SetLocationFlowController?
    internal var tabBarController: UITabBarController = UITabBarController()

    weak var delegate: AuthUIPresenterFlow?

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

        switch location.route() {
        case .config:
            #if DEBUG
                self.childFlows[Route.tokenList.rawValue]?.navigationHandler?(location)
            #else
                break
            #endif
        case .newToken:
            self.tabBarController.selectedIndex = 1
        default:
            break
        }
    }

    required init(configure: FlowConfigurable) {
        self.configure = configure
    }

    func start() {

        if let storyboardTabBar = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarController = storyboardTabBar
        }

        // Create tab flow controllers
        createNavigationController(route: .tokenList, tabBarController: tabBarController)
        createNavigationController(route: .newToken, tabBarController: tabBarController)
        createNavigationController(route: .settings, tabBarController: tabBarController)
        configure.navigationController?.setViewControllers([tabBarController], animated: false)

        let args = ProcessInfo.processInfo.arguments
        let uiTestMode = args.contains("UI_TEST_MODE")

        if preferences.site() == nil && !uiTestMode {
            let configuration =  FlowConfigure(window: nil, navigationController: self.configure.navigationController, parent: self)
            setLocationFlowController = SetLocationFlowController(configure: configuration)
            setLocationFlowController?.preferences = preferences
            setLocationFlowController?.start()
        }
    }

    private func createNavigationController(route: Route, tabBarController: UITabBarController) {

        let navigationController = UINavigationController()
        let icon = StyleManager.icon(route: route)
        navigationController.tabBarItem = UITabBarItem(title: route.tabTitle(), image: icon, tag: route.tabTag())
        childNavControllers[route.rawValue] = navigationController

        let flowConfig = FlowConfigure(window: nil, navigationController: childNavControllers[route.rawValue], parent: self)
        var flowController: FlowController?

        switch route {
        case .tokenList:
            let tokensFlowController = TokensFlowController(configure: flowConfig)
            tokensFlowController.delegate = self.delegate
            flowController = tokensFlowController
        case .newToken:
            flowController = NewTokenFlowController(configure: flowConfig)
        case .settings:
            let settingsFlowController = SettingsFlowController(configure: flowConfig)
            settingsFlowController.delegate = self.delegate
            flowController = settingsFlowController
        default:
            flowController = nil
        }

        childFlows[route.rawValue] = flowController

        tabBarController.addChildViewController(navigationController)
        flowController?.start()
    }

    func defaultFlow(location: Location) {
        self.childFlows[Route.tokenList.rawValue]?.navigationHandler?(location)
    }
}
