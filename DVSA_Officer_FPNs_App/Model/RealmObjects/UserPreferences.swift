//
//  UserPreferences.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 23/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

class UserPreferences: Object {
    @objc dynamic var username: String = ""
    @objc dynamic var siteLocation: SiteObject?
    @objc dynamic var mobileLocation: SiteObject?
    @objc dynamic var mobileAddress: String?
    @objc dynamic var isMobile: Bool = false

    override public class func primaryKey() -> String? {
        return "username"
    }
}
