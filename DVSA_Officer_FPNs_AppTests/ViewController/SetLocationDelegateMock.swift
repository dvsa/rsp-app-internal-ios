//
//  SetLocationDelegateMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 12/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class SetLocationDelegateMock: SetLocationDelegate {

    var site: SiteObject?
    var mobileAddress: String?

    var done = TestDone()
    func didConfirmLocation(site: SiteObject?, mobileAddress: String?) {
        self.site = site
        self.mobileAddress = mobileAddress
        done["didConfirmLocation"] = true
    }
    func didTapChangeLocation() {
        done["didTapChangeLocation"] = true
    }
}
