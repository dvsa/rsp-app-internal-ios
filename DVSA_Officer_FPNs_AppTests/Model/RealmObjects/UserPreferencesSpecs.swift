//
//  UserPreferencesSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class UserPreferencesSpecs: QuickSpec {

    override func spec() {

        var site: SiteObject?

        beforeEach {
            site = SiteObject()
            site?.code = 300
            site?.name = "London"
            site?.region = "West England"
        }

        describe("UserPreferences") {
            context("init") {
                it("should init with AWSBodyModel") {

                    let userPreferences = UserPreferences()
                    expect(userPreferences.siteLocation).to(beNil())
                    expect(userPreferences.username).to(equal(""))

                    userPreferences.siteLocation = site
                    userPreferences.username = "test.user"

                    expect(userPreferences.username).to(equal("test.user"))
                    expect(userPreferences.siteLocation?.name).to(equal("London"))
                    expect(userPreferences.siteLocation?.region).to(equal("West England"))
                    expect(userPreferences.siteLocation?.code).to(equal(300))

                    site?.code = 220
                    site?.name = "Nottingham"
                    site?.region = "East England"

                    expect(userPreferences.username).to(equal("test.user"))
                    expect(userPreferences.siteLocation?.name).to(equal("Nottingham"))
                    expect(userPreferences.siteLocation?.region).to(equal("East England"))
                    expect(userPreferences.siteLocation?.code).to(equal(220))
                }
            }

            context("primaryKey") {
                it("should equal username") {
                    expect(UserPreferences.primaryKey()).to(equal("username"))
                }
            }
        }
    }
}
