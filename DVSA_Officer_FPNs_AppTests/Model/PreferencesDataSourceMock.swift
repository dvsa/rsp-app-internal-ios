//
//  PreferencesDataSourceMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 06/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RealmSwift

@testable import DVSA_Officer_FPNs_App

class PreferencesDataSourceMock: PreferencesDataSourceProtocol {

    func updateMobileSite(site: SiteObject, mobileAddress: String) -> Bool {
        done["updateMobileSite"] = true
        userPreferencesObject.mobileAddress = mobileAddress
        userPreferencesObject.mobileLocation = site
        return true
    }

    var siteObject: SiteObject
    var userPreferencesObject = UserPreferences()

    var done = TestDone()

    init() {
        siteObject = SiteObject()
        siteObject.name = "London"
        siteObject.code = 6
        siteObject.region = "West England"
        userPreferencesObject.username =  "sherlock.holmes@dvsa.gov.uk"
        userPreferencesObject.siteLocation = siteObject
    }

    var userID: String? = "test-user-id"

    var username: String? {
        get {
            return userPreferencesObject.username
        }

        set (newUsername) {
            userPreferencesObject.username = newUsername ?? ""
        }
    }

    func userPreferences() -> UserPreferences? {
        return userPreferencesObject
    }
    func updateSite(site: SiteObject) -> Bool {
        done["updateSite"] = true
        userPreferencesObject.siteLocation = site
        return true
    }

    func site() -> SiteObject? {
        return userPreferencesObject.siteLocation
    }

    func getSite(code: Int) -> SiteObject? {
        if code == 6 {
            return userPreferencesObject.siteLocation
        }
        return nil
    }

    func clean() -> Bool {
        done["clean"] = true
        return true
    }

    func observePreferenceChange(completion: @escaping (UserPreferences?) -> Void) -> NotificationToken? {
        done["observePreferenceChange"] = true
        completion(userPreferencesObject)
        return nil
    }

    func subscribeUserPreferences(isFirstLogin: Bool) {
        done["subscribeUserPreferences"] = true
        done["isFirstLogin"] = isFirstLogin
    }

    func unsubscribeUserPreferences(completion: @escaping () -> Void) {
        done["unsubscribeUserPreferences"] = true
        completion()
    }

}
