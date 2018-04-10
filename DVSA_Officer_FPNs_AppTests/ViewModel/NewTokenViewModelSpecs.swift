//
//  NewTokenViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 30/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class NewTokenViewModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("NewTokenViewModel") {
            let viewModel = NewTokenViewModel()
            context("init") {
                it("should not be nil") {
                    expect(viewModel).notTo(beNil())
                }
                it("document token should not be nil") {
                    expect(viewModel.model).notTo(beNil())
                }
            }
            context("Test did set") {
                it("should set value and update flags") {
                    let newDoc = NewTokenModel(value: nil)
                    newDoc.dateTime = Date()
                    newDoc.referenceNo = "1231-1-222-IM"
                    newDoc.penaltyAmount = "666"
                    newDoc.vehicleRegNo = "LD12HHH"
                    newDoc.penaltyType = PenaltyType.immobilization
                    viewModel.model = newDoc
                    expect(viewModel.isRefValid).to(beTrue())
                    expect(viewModel.isDateValid).to(beTrue())
                    expect(viewModel.isAmountValid).to(beTrue())
                    expect(viewModel.isVehRegValid).to(beTrue())
                    expect(viewModel.isValidDocument()).to(beTrue())

                    newDoc.referenceNo = "1231-2-222-IM"
                    viewModel.model = newDoc
                    expect(viewModel.isRefValid).to(beFalse())
                    expect(viewModel.isValidDocument()).to(beFalse())

                    newDoc.referenceNo = "1231-0-222-IM"
                    viewModel.model = newDoc
                    expect(viewModel.isRefValid).to(beTrue())
                    expect(viewModel.isValidDocument()).to(beTrue())

                    newDoc.referenceNo = "1231-01-222-IM"
                    viewModel.model = newDoc
                    expect(viewModel.isRefValid).to(beFalse())
                    expect(viewModel.isValidDocument()).to(beFalse())
                }
            }
            context("Test updates") {
                it("update token ref") {
                    viewModel.updateRefNumber(refNumber: "1231-1-222-IM")
                    expect(viewModel.model.referenceNo).to(equal("1231-1-222-IM"))
                    expect(viewModel.isRefValid).to(beTrue())

                    viewModel.updateRefNumber(refNumber: "1231-3-222-IM")
                    expect(viewModel.model.referenceNo).to(equal("1231-3-222-IM"))
                    expect(viewModel.isRefValid).to(beFalse())
                    expect(viewModel.invalidInfoMessage().contains("Please recheck the reference number")).to(beTrue())
                }
                it("update vehicle reg") {
                    viewModel.updateVehicleReg(vehicleRegNo: "hhh")
                    expect(viewModel.model.vehicleRegNo).to(equal("hhh"))
                    expect(viewModel.isVehRegValid).toNot(beTrue())
                    expect(viewModel.invalidInfoMessage().contains("Please recheck the registration number")).to(beTrue())
                }
                it("update amount") {
                    viewModel.updatePenaltyAmount(penaltyAmount: "666")
                    expect(viewModel.model.penaltyAmount).to(equal("666"))
                    expect(viewModel.isAmountValid).to(beTrue())

                    viewModel.updatePenaltyAmount(penaltyAmount: "1")
                    expect(viewModel.model.penaltyAmount).to(equal("1"))
                    expect(viewModel.isAmountValid).toNot(beTrue())
                }
                it("update date") {
                    viewModel.updateDateTime(dateTime: Date(timeIntervalSince1970: 1516898361))
                    expect(viewModel.model.dateTime?.dvsaDateString).to(equal("25/01/2018"))
                    // The day is too early, more than 29 days
                    expect(viewModel.isDateValid).to(beFalse())
                    expect(viewModel.invalidInfoMessage().contains("Please recheck the date")).to(beTrue())
                }
            }
        }
    }
}
