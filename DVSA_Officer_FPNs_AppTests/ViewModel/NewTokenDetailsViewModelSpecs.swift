//
//  NewTokenDetailsViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 05/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class NewTokenDetailsViewModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("NewTokenDetailsViewModel") {

            var datasource: PersistentDataSourceMock!
            let tokenEncryptionKey: [UInt32] = [0x00, 0x01, 0x02, 0x03]

            context("init with empty model") {
                it("should be nil") {

                    datasource = PersistentDataSourceMock()
                    let model = NewTokenModel(value: nil)
                    let viewModel = try? NewTokenDetailsViewModel(model: model,
                                                                  preferences: PreferencesDataSourceMock(),
                                                                  datasource: datasource,
                                                                  key: tokenEncryptionKey)
                    expect(viewModel).to(beNil())

                    let model2 = NewTokenModel(value: nil)
                    model2.referenceNo = "213231"
                    let viewModel2 = try? NewTokenDetailsViewModel(model: model2,
                                                                   preferences: PreferencesDataSourceMock(),
                                                                  datasource: datasource,
                                                                  key: tokenEncryptionKey)
                    expect(viewModel2).to(beNil())

                    let model3 = NewTokenModel(value: nil)
                    model3.penaltyAmount = "2131"
                    let viewModel3 = try? NewTokenDetailsViewModel(model: model3,
                                                                   preferences: PreferencesDataSourceMock(),
                                                                   datasource: datasource,
                                                                   key: tokenEncryptionKey)
                    expect(viewModel3).to(beNil())
                }
            }

            context("init with valued model") {
                it("should not be nil") {

                    datasource = PersistentDataSourceMock()
                    let preferences = PreferencesDataSourceMock()

                    let model = NewTokenModel(value: nil)
                    model.dateTime = Date()
                    model.referenceNo = "1234-1-567890-IM"
                    model.penaltyAmount = "66"
                    model.vehicleRegNo = "LD12HHH"
                    model.penaltyType = PenaltyType.immobilization

                    let viewModel = try? NewTokenDetailsViewModel(model: model,
                                                                  preferences: preferences,
                                                                  datasource: datasource,
                                                                  key: tokenEncryptionKey)
                    expect(viewModel).toNot(beNil())
                    expect(datasource.done["insert"]).to(beTrue())
                    expect(datasource.itemObject?.hashToken).to(equal("New"))
                    expect(datasource.itemObject?.key).to(equal("0012341567890_IM"))
                    expect(datasource.itemObject?.enabled).to(beTrue())
                    expect(datasource.itemObject?.offset).toNot(beNil())
                    expect(datasource.itemObject?.value?.getPenaltyType()).to(equal(PenaltyType.immobilization))
                    expect(datasource.itemObject?.value?.getPaymentStatus()).to(equal(PaymentStatus.unpaid))
                    expect(datasource.itemObject?.value?.penaltyAmount).to(equal("66"))
                    expect(datasource.itemObject?.value?.vehicleDetails?.regNo).to(equal("LD12HHH"))
                    expect(datasource.itemObject?.value?.referenceNo).to(equal("1234-1-567890-IM"))
                    expect(datasource.itemObject?.value?.paymentToken).to(equal("2ccaf374c70476b7"))
                    expect(datasource.itemObject?.value?.siteCode).to(equal(6))
                    expect(datasource.itemObject?.value?.officerID).to(equal("test-user-id"))
                    expect(datasource.itemObject?.value?.officerName).to(equal("sherlock.holmes@dvsa.gov.uk"))
                    expect(datasource.itemObject?.value?.placeWhereIssued).to(equal("London"))

                    expect(viewModel?.sharableToken).to(equal("2cca-f374-c704-76b7"))
                }
            }
        }
    }
}
