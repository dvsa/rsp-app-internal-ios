//
//  SiteListTableViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class SiteListTableViewControllerSpecs: QuickSpec {

    override func spec() {
        describe("SiteListTableViewControllerSpecs") {

            let storyboard = UIStoryboard.mainStoryboard()!
            var viewController: SiteListTableViewController?

            beforeEach {
                viewController = SiteListTableViewController.instantiateFromStoryboard(storyboard)
            }

            it("Should instantiate from Storyboard") {
                expect(viewController).toNot(beNil())
            }
        }
    }
}
