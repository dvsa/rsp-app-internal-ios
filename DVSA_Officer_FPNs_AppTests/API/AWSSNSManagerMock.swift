//
//  AWSSNSManagerMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 15/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class AWSSNSManagerMock: AWSSNSManagerDelegate {

    var done = TestDone()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        done["didFinishLaunchingWithOptions"] = true
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        done["didRegisterForRemoteNotificationsWithDeviceToken"] = true
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        done["didFailToRegisterForRemoteNotificationsWithError"] = true
    }

    func registerToken(user: String?) {
        done["registerToken"] = true
    }

    func unsubscribe(completion: @escaping (Bool) -> Void) {
        done["unsubscribe"] = true
    }

}
