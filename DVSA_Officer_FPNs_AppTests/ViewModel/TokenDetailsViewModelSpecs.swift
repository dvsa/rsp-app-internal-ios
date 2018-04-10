//
//  TokenDetailsViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 20/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class TokenDetailsViewModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("TokenDetailsViewModel") {

            context("empty model") {

                var viewModel: TokenDetailsViewModel!

                it("should set fields") {
                    let body = BodyObject()
                    body.enabled = true
                    viewModel = TokenDetailsViewModel(model: body)
                    expect(viewModel.title).to(equal("Payment code for  - "))
                    expect(viewModel.isPaid).to(beFalse())
                    expect(viewModel.registrationNo).to(equal("Reg:  - "))
                    expect(viewModel.paymentStatus).to(equal("UNPAID"))
                    expect(viewModel.paymentToken).to(equal(""))
                    expect(viewModel.notifyStatus).to(equal(""))
                    expect(viewModel.referenceNo).to(equal(""))
                    expect(viewModel.penaltyAmount).to(equal("£0"))
                    expect(viewModel.siteLocation).to(equal(""))
                    expect(viewModel.penaltyType).to(equal(""))
                    expect(viewModel.penaltyDate).to(equal(""))
                    expect(viewModel.paymentDate).to(equal(" - "))
                    expect(viewModel.authorizationCode).to(equal(" - "))
                }
            }

            context("init with paid body") {

                var viewModel: TokenDetailsViewModel!
                let date = Date()

                beforeEach {

                    let body = DataMock.shared.bodyModel!
                    let bodyObj = BodyObject(model: body)!
                    bodyObj.value?.setPaymentStatus(paymentStatus: PaymentStatus.paid)
                    bodyObj.value?.paymentAuthCode = "3156"
                    bodyObj.value?.paymentDate = date
                    viewModel = TokenDetailsViewModel(model: bodyObj)
                }

                it("should set fields") {

                    expect(viewModel.title).to(equal("Payment code for XXXXXXX"))
                    expect(viewModel.isPaid).to(beTrue())
                    expect(viewModel.registrationNo).to(equal("Reg: XXXXXXX"))
                    expect(viewModel.paymentStatus).to(equal("PAID"))
                    expect(viewModel.paymentToken).to(equal("4e00-4da3-7939-110b"))
                    expect(viewModel.notifyStatus).to(equal(""))
                    expect(viewModel.referenceNo).to(equal("820500000877"))
                    expect(viewModel.penaltyAmount).to(equal("£50"))
                    expect(viewModel.siteLocation).to(equal("BLACKWALL TUNNEL A, PAVIL..."))
                    expect(viewModel.penaltyType).to(equal("Fixed penalty"))
                    expect(viewModel.penaltyDate).to(equal("11/10/2016"))
                    expect(viewModel.paymentDate).to(equal(date.dvsaDateTimeString))
                    expect(viewModel.authorizationCode).to(equal("3156"))
                }
            }

            context("init with valued model") {

                var viewModel: TokenDetailsViewModel!

                beforeEach {
                    let body = DataMock.shared.bodyModel!
                    let bodyObj = BodyObject(model: body)!
                    viewModel = TokenDetailsViewModel(model: bodyObj)
                }

                it("should set fields") {
                    expect(viewModel.title).to(equal("Payment code for XXXXXXX"))
                    expect(viewModel.isPaid).to(beFalse())
                    expect(viewModel.registrationNo).to(equal("Reg: XXXXXXX"))
                    expect(viewModel.paymentStatus).to(equal("UNPAID"))
                    expect(viewModel.paymentToken).to(equal("4e00-4da3-7939-110b"))
                    expect(viewModel.notifyStatus).to(equal(""))
                    expect(viewModel.referenceNo).to(equal("820500000877"))
                    expect(viewModel.penaltyAmount).to(equal("£50"))
                    expect(viewModel.siteLocation).to(equal("BLACKWALL TUNNEL A, PAVIL..."))
                    expect(viewModel.penaltyType).to(equal("Fixed penalty"))
                    expect(viewModel.penaltyDate).to(equal("11/10/2016"))
                    expect(viewModel.paymentDate).to(equal(" - "))
                    expect(viewModel.authorizationCode).to(equal(" - "))
                }
            }

            context("disabled body") {

                var viewModel: TokenDetailsViewModel!

                beforeEach {
                    let body = DataMock.shared.bodyModel!
                    let bodyObj = BodyObject(model: body)!
                    bodyObj.enabled = false
                    viewModel = TokenDetailsViewModel(model: bodyObj)
                }

                it("should set fields") {
                    expect(viewModel.isEnabled).to(beFalse())
                    expect(viewModel.titleTextColor == .dvsaRed).to(beTrue())
                    expect(viewModel.paymentStatus).to(equal("Cancelled"))
                }
            }
        }
    }
}
