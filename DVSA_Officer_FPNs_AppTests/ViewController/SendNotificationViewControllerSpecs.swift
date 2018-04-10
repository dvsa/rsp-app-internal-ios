//
//  SendNotificationViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class SendNotificationDelegateMock: SendNotificationDelegate {

    var done = TestDone()

    func didSendNotification() {
        done["didSendNotification"] = true
    }
}

class SendNotificationViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        var viewController: SendNotificationViewController!
        var viewModel: DriverNotificationViewModel?
        var sendNotificationDelegate: SendNotificationDelegateMock?

        beforeEach {
            viewController = SendNotificationViewController.instantiateFromStoryboard(UIStoryboard.mainStoryboard()!)
            sendNotificationDelegate = SendNotificationDelegateMock()
            viewController.sendNotificationDelegate = sendNotificationDelegate
        }

        describe("SendNotificationViewController") {
            it("Should instantiate from Storyboard") {
                expect(viewController).toNot(beNil())
            }

            it("UI components should not be nil") {

                _ = viewController.view
                expect(viewController.addressTextLabel).toNot(beNil())
                expect(viewController.addressValueTextField).toNot(beNil())
                expect(viewController.sendButton).toNot(beNil())
                expect(viewController.invalidInfoButton).toNot(beNil())
                expect(viewController.addressExampleLabel).toNot(beNil())

                expect(viewController.addressTextLabel.accessibilityIdentifier).to(equal("addressTextLabel"))
                expect(viewController.addressValueTextField.accessibilityIdentifier).to(equal("addressValueTextField"))
                expect(viewController.sendButton.accessibilityIdentifier).to(equal("sendButton"))
                expect(viewController.invalidInfoButton.accessibilityIdentifier).to(equal("invalidInfoButton"))
                expect(viewController.addressExampleLabel.accessibilityIdentifier).to(equal("addressExampleLabel"))
                expect(viewController.addressTextLabel.isAccessibilityElement).to(beTrue())
                expect(viewController.addressValueTextField.isAccessibilityElement).to(beTrue())
                expect(viewController.sendButton.isAccessibilityElement).to(beTrue())
                expect(viewController.invalidInfoButton.isAccessibilityElement).to(beTrue())
                expect(viewController.addressExampleLabel.isAccessibilityElement).to(beTrue())
            }

            describe("sms") {
                beforeEach {
                    viewModel = DriverNotificationViewModel(type: .sms,
                                                            vehicleReg: "Test vehicleReg",
                                                            location: "Test Location",
                                                            amount: 1000,
                                                            token: "1356456246")
                    viewController.viewModel = viewModel
                    _ = viewController.view

                }
                context("viewDidLoad") {
                    it("updateUI") {
                        expect(viewController.addressTextLabel.text).to(equal("SMS payment code details to"))
                        expect(viewController.addressValueTextField.keyboardType).to(equal(UIKeyboardType.phonePad))
                        expect(viewController.addressExampleLabel.text).to(equal("e.g. 00487777123456"))
                        expect(viewController.sendButton.titleLabel?.text).to(equal("Send payment code"))
                        expect(viewController.title).to(equal("Send payment code by SMS"))
                        expect(viewController.sendButton.isEnabled).to(beFalse())
                    }

                    it("updateSendButton") {

                        viewController.updateSendButton(address: nil)
                        expect(viewController.sendButton.isEnabled).to(beFalse())

                        viewController.updateSendButton(address: "")
                        expect(viewController.sendButton.isEnabled).to(beFalse())

                        viewController.updateSendButton(address: "+440000000001")
                        expect(viewController.sendButton.isEnabled).to(beTrue())
                    }
                }
            }

            describe("email") {
                beforeEach {
                    viewModel = DriverNotificationViewModel(type: .email,
                                                            vehicleReg: "Test vehicleReg",
                                                            location: "Test Location",
                                                            amount: 1000,
                                                            token: "1356456246")
                    viewController.viewModel = viewModel
                    _ = viewController.view

                }
                context("viewDidLoad") {
                    it("updateUI") {
                        expect(viewController.addressTextLabel.text).to(equal("E-mail payment code details to"))
                       expect(viewController.addressValueTextField.keyboardType).to(equal(UIKeyboardType.emailAddress))
                        expect(viewController.addressExampleLabel.text).to(equal("e.g. username@example.com"))
                        expect(viewController.sendButton.titleLabel?.text).to(equal("Send payment code"))
                        expect(viewController.title).to(equal("Send payment code by e-mail"))
                        expect(viewController.sendButton.isEnabled).to(beFalse())
                    }

                    it("updateSendButton") {

                        viewController.updateSendButton(address: nil)
                        expect(viewController.sendButton.isEnabled).to(beFalse())

                        viewController.updateSendButton(address: "")
                        expect(viewController.sendButton.isEnabled).to(beFalse())

                        viewController.updateSendButton(address: "sherlock.holmes@dvsa.gov.uk")
                        expect(viewController.sendButton.isEnabled).to(beTrue())
                    }
                    context("show/hide invalid info helper") {
                        it("hide UI") {
                            viewController.updateInvalidHelperUI(hideUI: true)
                            expect(viewController.invalidInfoButton.isHidden).to(beTrue())
                            expect(viewController.addressValueTextField.textColor).to(equal(.black))
                        }

                        it("show UI") {
                            viewController.updateInvalidHelperUI(hideUI: false)
                            expect(viewController.invalidInfoButton.isHidden).to(beFalse())
                            expect(viewController.addressValueTextField.textColor).to(equal(.dvsaRed))
                        }
                    }
                }

            }
        }
    }

}
