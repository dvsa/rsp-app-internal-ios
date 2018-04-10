//
//  SettingsViewControllerSpecs.swift
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

class SettingsViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("SettingsViewController") {

            var vc: SettingsViewController?
            let setLocationDelegate = SetLocationDelegateMock()
            var authUIMock: AuthUIPresenterFlowMock!

            beforeEach {
                authUIMock = AuthUIPresenterFlowMock()
                vc = SettingsViewController.instantiateFromStoryboard(UIStoryboard.mainStoryboard()!)
                vc?.setLocationDelegate = setLocationDelegate
                vc?.authUIDelegate = authUIMock
                UIApplication.shared.keyWindow!.rootViewController = vc
                _ = vc?.view

            }

            it("Should not be nil") {

                expect(vc).toNot(beNil())
                expect(vc?.title).to(equal("Settings"))
                expect(vc?.versionLabel.text).to(contain("version"))
            }

            it("Should implement BaseSiteChangeViewController") {
                expect(vc).toNot(beNil())
                expect(vc?.changeSiteLocationView).toNot(beNil())
                expect(vc?.changeSiteLocationView.setLocationDelegate).toNot(beNil())
                expect(vc?.changeSiteLocationView.changeButton).toNot(beNil())
                expect(vc?.changeSiteLocationView.siteLabel).toNot(beNil())
            }

            it("Outlets not be nil") {
                expect(vc?.logOutButton).toNot(beNil())
                expect(vc?.sendLogButton).toNot(beNil())
                expect(vc?.versionLabel).toNot(beNil())
            }

            it("MailHelper not be nil") {
                expect(vc?.mailHelper).toNot(beNil())
                expect(vc?.mailHelper?.hostViewController).toNot(beNil())
                expect(vc?.mailHelper?.hostViewController == vc).to(beTrue())
            }

            it("should call logout") {
                vc?.logOutButton.sendActions(for: UIControlEvents.touchUpInside)
                expect(authUIMock.done["logout"]).to(beTrue())
            }
        }
    }
}
