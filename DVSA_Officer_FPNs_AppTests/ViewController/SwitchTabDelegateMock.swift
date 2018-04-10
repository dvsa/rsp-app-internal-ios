//
//  SwitchTabDelegateMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 29/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class SwitchTabDelegateMock: SwitchTabDelegate {

    var done = TestDone()

    func switchToRoute(route: Route) {
        done["didChangeTab"] = true
    }
}
