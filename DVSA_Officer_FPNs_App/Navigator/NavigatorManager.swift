//
//  NavigatorManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Compass

//Define here all the routes for DeepLinking
enum Route: String {
    case login = "login"
    case logout = "logout"
    case config = "config"
    case tokenList = "tokenList"
    case newToken = "newToken"
    case notifications = "notifications"
    case settings = "settings"
    case unknown = ""
    static let routes: [String] = ["config", "login", "logout", "tokenList", "newToken", "notifications", "settings"]

    func tabTag() -> Int {
        switch self {
        case .tokenList:
            return 0
        case .newToken:
            return 1
        case .settings:
            return 2
        default:
            return 0
        }
    }

    func tabTitle() -> String {
        switch self {
        case .tokenList:
            return "Payment codes"
        case .newToken:
            return "New payment code"
        case .settings:
            return "Settings"
        default:
            return ""
        }
    }
}

extension Location {
    func route() -> Route {
        if let route = Route(rawValue: self.path) {
            return route
        } else {
            return .unknown
        }
    }
}

class NavigatorManager {

    static let shared = NavigatorManager()

    private var rootFlowController: FlowController?

    init() {
        //Setup Compass
        Navigator.scheme = Environment.bundleURLSchema()
        Navigator.routes = Route.routes
    }

    func assignFlowController(rootFlowController: FlowController) {
        self.rootFlowController = rootFlowController
        Navigator.handle = { [weak self] location in

            guard let rootFlow = self?.rootFlowController as? RootFlowController else { return }
            rootFlow.navigationHandler?(location)
        }
    }

    func handle(url: URL) -> Bool {
        do {
            try Navigator.navigate(url: url)
        } catch {
            // Handle error
        }
        return true
    }
}
