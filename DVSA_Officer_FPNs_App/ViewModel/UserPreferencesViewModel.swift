//
//  UserPreferencesViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 23/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class UserPreferencesViewModel {

    let model: UserPreferences?
    var temporarySiteLocation: SiteObject?
    var temporaryMobileLocation: SiteObject?
    var temporaryMobileAddress: String?
    var isMobile: Bool

    func isValid() -> Bool {
        if isMobile {
            guard let site = temporaryMobileLocation else {
                return false
            }
            if site.code  < 0 &&
                site.name != "" &&
                temporaryMobileAddress != nil &&
                temporaryMobileAddress != "" {
                return true
            }
            return false
        } else {
            guard let site = temporarySiteLocation else {
                return false
            }
            if site.code  > 0 &&
                site.name != "" {
                return true
            }
            return false
        }
    }

    let datasource: PreferencesDataSourceProtocol

    init(datasource: PreferencesDataSourceProtocol) {
        self.datasource = datasource
        self.model = datasource.userPreferences()
        self.temporarySiteLocation = model?.siteLocation
        self.isMobile = model?.isMobile ?? false
        self.temporaryMobileAddress = model?.mobileAddress
        self.temporaryMobileLocation = model?.mobileLocation
    }
}
