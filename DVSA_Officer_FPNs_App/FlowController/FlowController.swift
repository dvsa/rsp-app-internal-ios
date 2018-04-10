//
//  FlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import Compass

enum FlowType {
    case main
    case navigation
}

protocol FlowConfigurable {
    var window: UIWindow? { get }
    var navigationController: UINavigationController? { get }
    var parent: FlowController? { get }
    func whichFlowAmI() -> FlowType?
}

struct FlowConfigure: FlowConfigurable {
    let window: UIWindow?
    let navigationController: UINavigationController?
    let parent: FlowController?

    func whichFlowAmI() -> FlowType? {
        if window != nil { return .main }
        if navigationController != nil { return .navigation }
        return nil
    }
}

// FlowController: http://merowing.info/2016/01/improve-your-ios-architecture-with-flowcontrollers/

protocol FlowController {
    init(configure: FlowConfigurable)
    func start()
    var navigationHandler: ((Location) -> Void)? { get }
}

protocol Flow {
    func defaultFlow(location: Location)
}
