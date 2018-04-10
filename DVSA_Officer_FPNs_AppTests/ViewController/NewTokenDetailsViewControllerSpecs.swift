//
//  NewTokenDetailsViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 26/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class NewTokenDetailsViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("NewTokenDetailsViewController") {

            let storyboard = UIStoryboard.mainStoryboard()!
            var viewController: NewTokenDetailsViewController!
            var newTokenDelegate: NewTokenDetailsDelegateMock!
            var whistleReachability: WhistleReachabilityMock!

            beforeEach {
                whistleReachability = WhistleReachabilityMock()
                viewController = NewTokenDetailsViewController.instantiateFromStoryboard(storyboard)
                UIApplication.shared.keyWindow!.rootViewController = viewController
                newTokenDelegate = NewTokenDetailsDelegateMock()
                viewController.newTokenDelegate = newTokenDelegate
                viewController.reachabilityObserver.whistleReachability = whistleReachability
                _ = viewController.loadView()

            }

            it("Should instantiate from Storyboard") {

                expect(viewController).toNot(beNil())

                expect(viewController.sendEmailButton).toNot(beNil())
                expect(viewController.sendSMSButton).toNot(beNil())
                expect(viewController.tokenTextLabel).toNot(beNil())
                expect(viewController.tokenValueLabel).toNot(beNil())
                expect(viewController.paymentTextLabel).toNot(beNil())
                expect(viewController.paymentValueLabel).toNot(beNil())

                expect(viewController.reachabilityObserver.name).to(equal("NewTokenDetailsViewController"))
                expect(viewController.reachabilityObserver.delegate).toNot(beNil())

            }

            it("viewWillAppear") {
                viewController.viewWillAppear(true)
                expect(viewController.reachabilityObserver).toNot(beNil())
                expect(whistleReachability.done["attachObserver"]).toEventually(beTrue())
            }

            it("viewWillDisappear") {
                viewController.viewWillDisappear(true)
                expect(viewController.reachabilityObserver).toNot(beNil())
                expect(whistleReachability.done["removeObserver"]).toEventually(beTrue())
            }

            context("reachabilityDidChange") {

                it("isReachable") {
                    viewController.reachabilityDidChange(isReachable: true)
                    expect(viewController.sendSMSButton.isEnabled).to(beTrue())
                    expect(viewController.sendEmailButton.isEnabled).to(beTrue())
                }

                it("not isReachable") {
                    viewController.reachabilityDidChange(isReachable: false)
                    expect(viewController.sendSMSButton.isEnabled).to(beFalse())
                    expect(viewController.sendEmailButton.isEnabled).to(beFalse())
                }
            }

            context("didTapSendEmail") {
                it("Should call newTokenDelegate delegate") {
                    viewController.didTapSendEmail(viewController)
                    expect(newTokenDelegate.done["didTapSendEmail"]).to(beTrue())
                }
            }

            context("didTapSendSMS") {
                it("Should call newTokenDelegate delegate") {
                    viewController.didTapSendSMS(viewController)
                    expect(newTokenDelegate.done["didTapSendSMS"]).to(beTrue())
                }
            }
        }
    }
}
