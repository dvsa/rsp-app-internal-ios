//
//  TokenDetailsViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 19/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class TokenDetailsViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("TokenDetailsViewController") {

            let storyboard = UIStoryboard.mainStoryboard()!
            var viewController: TokenDetailsViewController!
            var newTokenDelegate = NewTokenDetailsDelegateMock()
            var paidViewModel: TokenDetailsViewModel!
            var unpaidViewModel: TokenDetailsViewModel!
            var disabledViewModel: TokenDetailsViewModel!
            var whistleReachability: WhistleReachabilityMock!

            beforeEach {
                viewController = TokenDetailsViewController.instantiateFromStoryboard(storyboard)
                UIApplication.shared.keyWindow!.rootViewController = viewController
                newTokenDelegate = NewTokenDetailsDelegateMock()
                viewController.newTokenDelegate = newTokenDelegate
                _ = viewController.view

                let body = DataMock.shared.bodyModel!
                let bodyObj = BodyObject(model: body)!
                unpaidViewModel = TokenDetailsViewModel(model: bodyObj)

                bodyObj.enabled = false
                disabledViewModel = TokenDetailsViewModel(model: bodyObj)

                bodyObj.enabled = true
                bodyObj.value?.setPaymentStatus(paymentStatus: PaymentStatus.paid)
                bodyObj.value?.paymentAuthCode = "3156"
                bodyObj.value?.paymentDate = Date()
                paidViewModel = TokenDetailsViewModel(model: bodyObj)

                whistleReachability = WhistleReachabilityMock()
                viewController.reachabilityObserver.whistleReachability = whistleReachability
            }

            it("Should instantiate from Storyboard") {

                expect(viewController).toNot(beNil())
                expect(viewController.headerView).toNot(beNil())
                expect(viewController.registrationNoLabel).toNot(beNil())
                expect(viewController.paymentStatusLabel).toNot(beNil())
                expect(viewController.paidImageView).toNot(beNil())
                expect(viewController.titleSeparatorLine).toNot(beNil())

                expect(viewController.descritpionStackView).toNot(beNil())
                expect(viewController.valueStackView).toNot(beNil())

                expect(viewController.paymentTokenDescriptionLabel).toNot(beNil())
                expect(viewController.paymentTokenLabel).toNot(beNil())
                expect(viewController.notifyStatusLabel).toNot(beNil())

                expect(viewController.penaltyDetailsDescriptionLabel).toNot(beNil())

                expect(viewController.referenceNoDescriptionLabel).toNot(beNil())
                expect(viewController.penaltyAmountDescriptionLabel).toNot(beNil())
                expect(viewController.siteLocationDescriptionLabel).toNot(beNil())
                expect(viewController.penaltyTypeDescriptionLabel).toNot(beNil())
                expect(viewController.penaltyDateDescriptionLabel).toNot(beNil())
                expect(viewController.emptyDescriptionLabel).toNot(beNil())
                expect(viewController.paymentDateDescriptionLabel).toNot(beNil())
                expect(viewController.authorizationCodeDescriptionLabel).toNot(beNil())

                expect(viewController.separatorPenaltyDetails).toNot(beNil())

                expect(viewController.referenceNoLabel).toNot(beNil())
                expect(viewController.penaltyAmountLabel).toNot(beNil())
                expect(viewController.siteLocationLabel).toNot(beNil())
                expect(viewController.penaltyTypeLabel).toNot(beNil())
                expect(viewController.penaltyDateLabel).toNot(beNil())
                expect(viewController.emptyLabel).toNot(beNil())
                expect(viewController.paymentDateLabel).toNot(beNil())
                expect(viewController.authorizationCodeLabel).toNot(beNil())

                expect(viewController.buttonsStackView).toNot(beNil())
                expect(viewController.sendBySMSButton).toNot(beNil())
                expect(viewController.sendByEmailButton).toNot(beNil())
                expect(viewController.cancelTokenButton).toNot(beNil())

                expect(viewController.cancelledTokenInfo).toNot(beNil())
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
                    expect(viewController.sendBySMSButton.isEnabled).to(beTrue())
                    expect(viewController.sendByEmailButton.isEnabled).to(beTrue())
                    expect(viewController.cancelTokenButton.isEnabled).to(beTrue())
                }

                it("not isReachable") {
                    viewController.reachabilityDidChange(isReachable: false)
                    expect(viewController.sendBySMSButton.isEnabled).to(beFalse())
                    expect(viewController.sendByEmailButton.isEnabled).to(beFalse())
                    expect(viewController.cancelTokenButton.isEnabled).to(beFalse())
                }
            }

            it("Should apply style") {

                expect(viewController).toNot(beNil())
                expect(viewController.paymentTokenDescriptionLabel.text).to(equal("Payment code"))
                expect(viewController.penaltyDetailsDescriptionLabel.text).to(equal("Penalty details"))

                expect(viewController.referenceNoDescriptionLabel.text).to(equal("Reference:"))
                expect(viewController.penaltyAmountDescriptionLabel.text).to(equal( "Amount:"))
                expect(viewController.siteLocationDescriptionLabel.text).to(equal("Location:"))
                expect(viewController.penaltyTypeDescriptionLabel.text).to(equal("Type:"))
                expect(viewController.penaltyDateDescriptionLabel.text).to(equal("Issued on:"))
                expect(viewController.emptyDescriptionLabel.text).to(equal(" "))
                expect(viewController.paymentDateDescriptionLabel.text).to(equal("Paid on:"))
                expect(viewController.authorizationCodeDescriptionLabel.text).to(equal("Auth. code:"))
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

            context("didTapCancelToken") {
                it("Should call newTokenDelegate didTapRevokeToken") {
                    viewController.didTapCancelToken(viewController)
                    expect(newTokenDelegate.done["didTapRevokeToken"]).to(beTrue())
                }
            }

            context("viewModel didChange") {

                context("nil") {

                    it("updateUI") {
                        viewController.viewModel = nil

                        expect(viewController.title).to(equal(""))
                        expect(viewController.registrationNoLabel.text).to(equal(""))
                        expect(viewController.paymentStatusLabel.text).to(equal(""))
                        expect(viewController.paymentTokenLabel.text).to(equal(""))
                        expect(viewController.notifyStatusLabel.text).to(equal(""))
                        expect(viewController.referenceNoLabel.text).to(equal(""))
                        expect(viewController.penaltyAmountLabel.text).to(equal(""))
                        expect(viewController.siteLocationLabel.text).to(equal(""))
                        expect(viewController.penaltyTypeLabel.text).to(equal(""))
                        expect(viewController.penaltyDateLabel.text).to(equal(""))
                        expect(viewController.paymentDateLabel.text ).to(equal(""))
                        expect(viewController.authorizationCodeLabel.text).to(equal(""))
                    }
                }

                context("paid") {

                    it("updateUI") {
                        expect(paidViewModel.isPaid).to(beTrue())
                        let viewModel = paidViewModel!
                        viewController.viewModel = viewModel

                        expect(viewController.title).to(equal(viewModel.title))
                        expect(viewController.registrationNoLabel.text).to(equal(viewModel.registrationNo))
                        expect(viewController.paymentStatusLabel.text).to(equal(viewModel.paymentStatus))
                        expect(viewController.paymentTokenLabel.text).to(equal(viewModel.paymentToken))
                        expect(viewController.notifyStatusLabel.text).to(equal(viewModel.notifyStatus))
                        expect(viewController.referenceNoLabel.text).to(equal(viewModel.referenceNo))
                        expect(viewController.penaltyAmountLabel.text).to(equal(viewModel.penaltyAmount))
                        expect(viewController.siteLocationLabel.text).to(equal(viewModel.siteLocation))
                        expect(viewController.penaltyTypeLabel.text).to(equal(viewModel.penaltyType))
                        expect(viewController.penaltyDateLabel.text).to(equal(viewModel.penaltyDate))
                        expect(viewController.paymentDateLabel.text ).to(equal(viewModel.paymentDate))
                        expect(viewController.authorizationCodeLabel.text).to(equal(viewModel.authorizationCode))

                        expect(viewController.paidImageView.isHidden).to(beFalse())
                        expect(viewController.headerView.backgroundColor).to(equal(UIColor.dvsaGreen.withAlphaComponent(0.1)))
                        expect(viewController.buttonsStackView.isHidden).to(beTrue())
                        expect(viewController.separatorPenaltyDetails.isHidden).to(beFalse())

                        expect(viewController.emptyLabel.superview).to(equal(viewController.valueStackView))
                        expect(viewController.paymentDateLabel.superview).to(equal(viewController.valueStackView))
                        expect(viewController.authorizationCodeLabel.superview).to(equal(viewController.valueStackView))
                        expect(viewController.emptyDescriptionLabel.superview).to(equal(viewController.descritpionStackView))
                        expect(viewController.paymentDateDescriptionLabel.superview).to(equal(viewController.descritpionStackView))
                        expect(viewController.authorizationCodeDescriptionLabel.superview).to(equal(viewController.descritpionStackView))

                        expect(viewController.titleSeparatorLine.isHidden).to(beFalse())
                        expect(viewController.cancelledTokenInfo.isHidden).to(beTrue())
                        expect(viewController.paymentStatusLabel.textColor == .black).to(beTrue())

                    }
                }
                context("unpaid") {
                    it("updateUI") {
                        expect(unpaidViewModel.isPaid).to(beFalse())
                        let viewModel = unpaidViewModel!
                        viewController.viewModel = viewModel

                        expect(viewController.title).to(equal(viewModel.title))
                        expect(viewController.registrationNoLabel.text).to(equal(viewModel.registrationNo))
                        expect(viewController.paymentStatusLabel.text).to(equal(viewModel.paymentStatus))
                        expect(viewController.paymentTokenLabel.text).to(equal(viewModel.paymentToken))
                        expect(viewController.notifyStatusLabel.text).to(equal(viewModel.notifyStatus))
                        expect(viewController.referenceNoLabel.text).to(equal(viewModel.referenceNo))
                        expect(viewController.penaltyAmountLabel.text).to(equal(viewModel.penaltyAmount))
                        expect(viewController.siteLocationLabel.text).to(equal(viewModel.siteLocation))
                        expect(viewController.penaltyTypeLabel.text).to(equal(viewModel.penaltyType))
                        expect(viewController.penaltyDateLabel.text).to(equal(viewModel.penaltyDate))
                        expect(viewController.paymentDateLabel.text ).to(equal(viewModel.paymentDate))
                        expect(viewController.authorizationCodeLabel.text).to(equal(viewModel.authorizationCode))

                        expect(viewController.paidImageView.isHidden).to(beTrue())
                        expect(viewController.headerView.backgroundColor).to(equal(UIColor.white))
                        expect(viewController.buttonsStackView.isHidden).to(beFalse())
                        expect(viewController.separatorPenaltyDetails.isHidden).to(beTrue())

                        expect(viewController.emptyLabel.isHidden).to(beTrue())
                        expect(viewController.paymentDateLabel.isHidden).to(beTrue())
                        expect(viewController.authorizationCodeLabel.isHidden).to(beTrue())
                        expect(viewController.emptyDescriptionLabel.isHidden).to(beTrue())
                        expect(viewController.paymentDateDescriptionLabel.isHidden).to(beTrue())
                        expect(viewController.authorizationCodeDescriptionLabel.isHidden).to(beTrue())

                        expect(viewController.titleSeparatorLine.isHidden).to(beFalse())
                        expect(viewController.cancelledTokenInfo.isHidden).to(beTrue())
                        expect(viewController.paymentStatusLabel.textColor == .black).to(beTrue())
                    }
                }

                context("unpaid") {
                    it("updateUI") {
                        expect(disabledViewModel.isEnabled).to(beFalse())

                        let viewModel = disabledViewModel!
                        viewController.viewModel = viewModel

                        expect(viewController.title).to(equal(viewModel.title))
                        expect(viewController.registrationNoLabel.text).to(equal(viewModel.registrationNo))
                        expect(viewController.paymentStatusLabel.text).to(equal(viewModel.paymentStatus))
                        expect(viewController.paymentTokenLabel.text).to(equal(viewModel.paymentToken))
                        expect(viewController.notifyStatusLabel.text).to(equal(viewModel.notifyStatus))
                        expect(viewController.referenceNoLabel.text).to(equal(viewModel.referenceNo))
                        expect(viewController.penaltyAmountLabel.text).to(equal(viewModel.penaltyAmount))
                        expect(viewController.siteLocationLabel.text).to(equal(viewModel.siteLocation))
                        expect(viewController.penaltyTypeLabel.text).to(equal(viewModel.penaltyType))
                        expect(viewController.penaltyDateLabel.text).to(equal(viewModel.penaltyDate))
                        expect(viewController.paymentDateLabel.text ).to(equal(viewModel.paymentDate))
                        expect(viewController.authorizationCodeLabel.text).to(equal(viewModel.authorizationCode))

                        expect(viewController.paidImageView.isHidden).to(beFalse())
                        expect(viewController.headerView.backgroundColor).to(equal(.dvsaPinkBackground))
                        expect(viewController.buttonsStackView.isHidden).to(beTrue())
                        expect(viewController.separatorPenaltyDetails.isHidden).to(beTrue())

                        expect(viewController.titleSeparatorLine.isHidden).to(beTrue())
                        expect(viewController.cancelledTokenInfo.isHidden).to(beFalse())
                        expect(viewController.paymentStatusLabel.textColor == .dvsaRed).to(beTrue())

                        expect(viewController.emptyLabel.isHidden).to(beTrue())
                        expect(viewController.paymentDateLabel.isHidden).to(beTrue())
                        expect(viewController.authorizationCodeLabel.isHidden).to(beTrue())
                        expect(viewController.emptyDescriptionLabel.isHidden).to(beTrue())
                        expect(viewController.paymentDateDescriptionLabel.isHidden).to(beTrue())
                        expect(viewController.authorizationCodeDescriptionLabel.isHidden).to(beTrue())
                    }
                }
            }
        }
    }
}
