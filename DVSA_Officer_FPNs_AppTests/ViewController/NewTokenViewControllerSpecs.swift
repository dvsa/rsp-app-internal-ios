//
//  NewTokenViewControllerSpecs.swift
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

class NewTokenDelegateMock: NewTokenDelegate {

    var done = TestDone()

    func didTapStartOCRSession() {
        done["didTapStartOCRSession"] = true
    }

    func didTapCreateToken() {
        done["didTapCreateToken"] = true
    }
}

class NewTokenViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("NewTokenViewController") {

            var viewController: NewTokenViewController!
            let setLocationDelegate = SetLocationDelegateMock()
            var newTokenDelegate: NewTokenDelegateMock!
            var whistleReachability: WhistleReachabilityMock!

            let modelIM = NewTokenModel(value: nil)
            modelIM.dateTime = Date()
            modelIM.referenceNo = "12345-6-789012-IM"
            modelIM.penaltyAmount = "666"
            modelIM.vehicleRegNo = "LD12HHH"
            modelIM.penaltyType = PenaltyType.immobilization

            let modelFPN = NewTokenModel(value: nil)
            modelFPN.dateTime = Date()
            modelFPN.referenceNo = "123456789012"
            modelFPN.penaltyAmount = "666"
            modelFPN.vehicleRegNo = "LD12HHH"
            modelFPN.penaltyType = PenaltyType.fpn

            let modelCDN = NewTokenModel(value: nil)
            modelCDN.dateTime = Date()
            modelCDN.referenceNo = "123456789012"
            modelCDN.penaltyAmount = "666"
            modelCDN.vehicleRegNo = "LD12HHH"
            modelCDN.penaltyType = PenaltyType.deposit

            beforeEach {
                newTokenDelegate = NewTokenDelegateMock()
                whistleReachability = WhistleReachabilityMock()
                viewController = NewTokenViewController.instantiateFromStoryboard(UIStoryboard.mainStoryboard()!)
                viewController?.setLocationDelegate = setLocationDelegate
                viewController?.newTokenDelegate = newTokenDelegate
                viewController?.whistleReachability = whistleReachability

                UIApplication.shared.keyWindow!.rootViewController = viewController
                _ = viewController?.view
            }

            it("Should instantiate from Storyboard") {

                expect(viewController).toNot(beNil())

                expect(viewController.title).to(equal("New payment code"))
                expect(viewController.penaltyTypeSegmentedControl).toNot(beNil())
                expect(viewController.refNumberTextField).toNot(beNil())
                expect(viewController.vehicleRegTextField).toNot(beNil())
                expect(viewController.dateTimeTextField).toNot(beNil())
                expect(viewController.penaltyAmountTextField).toNot(beNil())
                expect(viewController.scanButton).toNot(beNil())
                expect(viewController.createButton).toNot(beNil())
                expect(viewController.referenceStackView).toNot(beNil())

                expect(viewController.referenceStackView).toNot(beNil())

                expect(viewController.clearAllButton).toNot(beNil())

                expect(viewController.imReference1TextField).toNot(beNil())
                expect(viewController.imReference2TextField).toNot(beNil())
                expect(viewController.im0Label).toNot(beNil())
                expect(viewController.im1Label).toNot(beNil())
                expect(viewController.im2Label).toNot(beNil())
                expect(viewController.imReferenceWidthConstraint).toNot(beNil())

                expect(viewController.refInvalidInfoBtn).toNot(beNil())
                expect(viewController.regInvalidInfoBtn).toNot(beNil())
                expect(viewController.amtInvalidInfoBtn).toNot(beNil())
                expect(viewController.dateInvalidInfoBtn).toNot(beNil())

                expect(viewController.imReferenceWidthConstraint.constant).to(equal(0))

                expect(viewController.penaltyTypeSegmentedControl.accessibilityIdentifier).to(equal("penaltyTypeSegmentedControll"))
                expect(viewController.refNumberTextField.accessibilityIdentifier).to(equal("refNumberTextField"))
                expect(viewController.vehicleRegTextField.accessibilityIdentifier).to(equal("vehicleRegTextField"))
                expect(viewController.dateTimeTextField.accessibilityIdentifier).to(equal("dateTimeTextField"))
                expect(viewController.penaltyAmountTextField.accessibilityIdentifier).to(equal("penaltyAmountTextField"))

                expect(viewController.imReference1TextField.accessibilityIdentifier).to(equal("imReference1TextField"))
                expect(viewController.imReference2TextField.accessibilityIdentifier).to(equal("imReference2TextField"))
                expect(viewController.im0Label.accessibilityIdentifier).to(equal("im0Label"))
                expect(viewController.im1Label.accessibilityIdentifier).to(equal("im1Label"))
                expect(viewController.im2Label.accessibilityIdentifier).to(equal("im2Label"))
                expect(viewController.scanButton.accessibilityIdentifier).to(equal("scanButton"))
                expect(viewController.createButton.accessibilityIdentifier).to(equal("createButton"))

                expect(viewController.refInvalidInfoBtn.accessibilityIdentifier).to(equal("invalidRefInfoButton"))
                expect(viewController.regInvalidInfoBtn.accessibilityIdentifier).to(equal("invalidRegInfoButton"))
                expect(viewController.amtInvalidInfoBtn.accessibilityIdentifier).to(equal("invalidAmountInfoButton"))
                expect(viewController.dateInvalidInfoBtn.accessibilityIdentifier).to(equal("invalidDateInfoButton"))

                expect(viewController.im0Label.text).to(equal("-"))
                expect(viewController.im1Label.text).to(equal("-"))
                expect(viewController.im2Label.text).to(equal("-IM"))

                expect(viewController.penaltyTypeSegmentedControl.isAccessibilityElement).to(beTrue())
                expect(viewController.refNumberTextField.isAccessibilityElement).to(beTrue())
                expect(viewController.vehicleRegTextField.isAccessibilityElement).to(beTrue())
                expect(viewController.dateTimeTextField.isAccessibilityElement).to(beTrue())
                expect(viewController.penaltyAmountTextField.isAccessibilityElement).to(beTrue())

                expect(viewController.imReference1TextField.isAccessibilityElement).to(beTrue())
                expect(viewController.imReference2TextField.isAccessibilityElement).to(beTrue())
                expect(viewController.im0Label.isAccessibilityElement).to(beTrue())
                expect(viewController.im1Label.isAccessibilityElement).to(beTrue())
                expect(viewController.im2Label.isAccessibilityElement).to(beTrue())

                expect(viewController.refInvalidInfoBtn.isAccessibilityElement).to(beTrue())
                expect(viewController.regInvalidInfoBtn.isAccessibilityElement).to(beTrue())
                expect(viewController.amtInvalidInfoBtn.isAccessibilityElement).to(beTrue())
                expect(viewController.dateInvalidInfoBtn.isAccessibilityElement).to(beTrue())

                expect(viewController.scanButton.isAccessibilityElement).to(beTrue())
                expect(viewController.createButton.isAccessibilityElement).to(beTrue())

                expect(viewController.penaltyTypeSegmentedControl.numberOfSegments).to(equal(3))
                expect(viewController.refNumberTextField.text).to(equal(""))
                expect(viewController.vehicleRegTextField.text).to(equal(""))
                expect(viewController.dateTimeTextField.text).to(equal(""))
                expect(viewController.penaltyAmountTextField.text).to(equal(""))
                expect(viewController.scanButton.isEnabled).to(beTrue())
                expect(viewController.createButton.isEnabled).to(beFalse())
            }

            it("clearAll") {

                viewController.viewModel.model = modelIM
                viewController.bindToViewModel(animated: false)
                let segmentCtrl = viewController?.penaltyTypeSegmentedControl
                expect(segmentCtrl?.selectedSegmentIndex).to(equal(Int(PenaltyType.immobilization.rawValue)))
                expect(viewController.refNumberTextField.text).to(equal("12345"))
                expect(viewController.imReference1TextField.text).to(equal("6"))
                expect(viewController.imReference2TextField.text).to(equal("789012"))
                expect(viewController.vehicleRegTextField.text).to(equal("LD12HHH"))
                expect(viewController.dateTimeTextField.text).toNot(equal(""))
                expect(viewController.penaltyAmountTextField.text).to(equal("666"))

                viewController.clearAll()

                let segmentCtrl1 = viewController?.penaltyTypeSegmentedControl
                expect(segmentCtrl1?.selectedSegmentIndex).to(equal(Int(PenaltyType.fpn.rawValue)))
                expect(viewController.refNumberTextField.text).to(equal(""))
                expect(viewController.imReference1TextField.text).to(equal(""))
                expect(viewController.imReference2TextField.text).to(equal(""))
                expect(viewController.vehicleRegTextField.text).to(equal(""))
                expect(viewController.dateTimeTextField.text).to(equal(""))
                expect(viewController.penaltyAmountTextField.text).to(equal(""))
            }

            it("Should show or hide IM fields") {

                let sc = viewController.penaltyTypeSegmentedControl
                let actions = sc?.actions(forTarget: viewController, forControlEvent: UIControlEvents.valueChanged)
                expect(actions?.contains("segmentedControlIndexChangedWithSender:")).to(beTrue())

                sc?.selectedSegmentIndex = 0
                sc?.sendActions(for: UIControlEvents.valueChanged)
                expect(viewController.refNumberTextField.text).to(equal(""))
                expect(viewController.imReference1TextField.text).to(equal(""))
                expect(viewController.imReference2TextField.text).to(equal(""))

                sc?.selectedSegmentIndex = 1
                sc?.sendActions(for: UIControlEvents.valueChanged)
                expect(viewController.imReferenceWidthConstraint.constant).to(equal(viewController.maxIMWidthConstraint))
                expect(viewController.refNumberTextField.text).to(equal(""))
                expect(viewController.imReference1TextField.text).to(equal(""))
                expect(viewController.imReference2TextField.text).to(equal(""))

                sc?.selectedSegmentIndex = 2
                sc?.sendActions(for: UIControlEvents.valueChanged)
                expect(viewController.imReferenceWidthConstraint.constant).to(equal(0))
                expect(viewController.refNumberTextField.text).to(equal(""))
                expect(viewController.imReference1TextField.text).to(equal(""))
                expect(viewController.imReference2TextField.text).to(equal(""))

            }

            context("bindToViewModel") {

                it("immobilization") {
                    viewController.viewModel.model = modelIM
                    viewController.bindToViewModel(animated: false)
                    expect(viewController.refNumberTextField.text).to(equal("12345"))
                    expect(viewController.imReference1TextField.text).to(equal("6"))
                    expect(viewController.imReference2TextField.text).to(equal("789012"))
                    expect(viewController.vehicleRegTextField.text).to(equal("LD12HHH"))
                    expect(viewController.dateTimeTextField.text).toNot(equal(""))
                    expect(viewController.penaltyAmountTextField.text).to(equal("666"))
                }

                it("fpn") {
                    viewController.viewModel.model = modelFPN
                    viewController.bindToViewModel(animated: false)
                    expect(viewController.refNumberTextField.text).to(equal("123456789012"))
                    expect(viewController.imReference1TextField.text).to(equal(""))
                    expect(viewController.imReference2TextField.text).to(equal(""))
                    expect(viewController.vehicleRegTextField.text).to(equal("LD12HHH"))
                    expect(viewController.dateTimeTextField.text).toNot(equal(""))
                    expect(viewController.penaltyAmountTextField.text).to(equal("666"))
                }

                it("deposit") {
                    viewController.viewModel.model = modelCDN
                    viewController.bindToViewModel(animated: false)
                    expect(viewController.refNumberTextField.text).to(equal("123456789012"))
                    expect(viewController.imReference1TextField.text).to(equal(""))
                    expect(viewController.imReference2TextField.text).to(equal(""))
                    expect(viewController.vehicleRegTextField.text).to(equal("LD12HHH"))
                    expect(viewController.dateTimeTextField.text).toNot(equal(""))
                    expect(viewController.penaltyAmountTextField.text).to(equal("666"))
                }

            }

            context("refNumberChanged") {
                it("immobilization") {
                    viewController.viewModel.model.penaltyType = .immobilization
                    viewController.bindToViewModel(animated: false)
                    viewController.refNumberTextField.text = "1"
                    viewController.imReference1TextField.text = "2"
                    viewController.imReference2TextField.text = "3"

                    viewController.refNumberTextField?.sendActions(for: UIControlEvents.editingChanged)
                    expect(viewController.viewModel.model.referenceNo).to(equal("1-2-3-IM"))

                    viewController.refNumberTextField.text = ""
                    viewController.imReference1TextField.text = "2"
                    viewController.imReference2TextField.text = ""

                    viewController.imReference1TextField?.sendActions(for: UIControlEvents.editingChanged)
                    expect(viewController.viewModel.model.referenceNo).to(equal("-2--IM"))

                    viewController.refNumberTextField.text = "1"
                    viewController.imReference1TextField.text = ""
                    viewController.imReference2TextField.text = "0"

                    viewController.imReference2TextField?.sendActions(for: UIControlEvents.editingChanged)
                    expect(viewController.viewModel.model.referenceNo).to(equal("1--0-IM"))
                }

                it("fpn or deposit") {
                    viewController.viewModel.model.penaltyType = .fpn
                    viewController.bindToViewModel(animated: false)
                    viewController.refNumberChanged(viewController)

                    viewController.refNumberTextField.text = "1"
                    viewController.imReference1TextField.text = ""
                    viewController.imReference2TextField.text = ""

                    viewController.refNumberTextField?.sendActions(for: UIControlEvents.editingChanged)
                    expect(viewController.viewModel.model.referenceNo).to(equal("1"))
                }
            }

            it("vehicleRegChanged") {
                viewController.vehicleRegTextField.text = "6721576"
                viewController.vehicleRegTextField.sendActions(for: UIControlEvents.editingChanged)
                expect(viewController.viewModel.model.vehicleRegNo).to(equal("6721576"))
            }

            it("penaltyAmountChanged") {
                viewController.penaltyAmountTextField.text = "2222"
                viewController.penaltyAmountTextField.sendActions(for: UIControlEvents.editingChanged)
                expect(viewController.viewModel.model.penaltyAmount).to(equal("2222"))
            }

            context("updateUIWithValidation") {
                it("fpn or deposit") {
                    viewController.viewModel.model = NewTokenModel(value: nil)
                    viewController.bindToViewModel(animated: false)
                    viewController.refNumberTextField.text = "123123123123"
                    viewController.refNumberTextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.refNumberTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isRefValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.vehicleRegTextField.text = "WEREER"
                    viewController.vehicleRegTextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.vehicleRegTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isVehRegValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.dateTimeTextField.sendActions(for: UIControlEvents.editingDidBegin)
                    viewController.dateTimeTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isDateValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.penaltyAmountTextField.text = "2018"
                    viewController.penaltyAmountTextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.penaltyAmountTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isAmountValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beTrue())
                    expect(viewController.createButton.isEnabled).to(beTrue())
                }

                it("immobilization") {
                    viewController.viewModel.model = NewTokenModel(value: nil)
                    viewController.viewModel.model.penaltyType = .immobilization
                    viewController.bindToViewModel(animated: false)
                    viewController.refNumberTextField.text = "123123"
                    viewController.refNumberTextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.refNumberTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isRefValid).to(beFalse())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.vehicleRegTextField.text = "WEREER"
                    viewController.vehicleRegTextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.vehicleRegTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isVehRegValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.dateTimeTextField.sendActions(for: UIControlEvents.editingDidBegin)
                    viewController.dateTimeTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isDateValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.penaltyAmountTextField.text = "2018"
                    viewController.penaltyAmountTextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.penaltyAmountTextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isAmountValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.imReference1TextField.text = "1"
                    viewController.imReference1TextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.imReference1TextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isRefValid).to(beFalse())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                    viewController.imReference2TextField.text = "3"
                    viewController.imReference2TextField.sendActions(for: UIControlEvents.editingChanged)
                    viewController.imReference2TextField.sendActions(for: UIControlEvents.editingDidEnd)
                    expect(viewController.viewModel.isRefValid).to(beTrue())
                    expect(viewController.viewModel.isValidDocument()).to(beTrue())
                    expect(viewController.createButton.isEnabled).to(beTrue())

                    viewController.penaltyTypeSegmentedControl.selectedSegmentIndex = Int(PenaltyType.fpn.rawValue)
                    viewController.penaltyTypeSegmentedControl.sendActions(for: UIControlEvents.valueChanged)
                    expect(viewController.viewModel.isRefValid).to(beFalse())
                    expect(viewController.viewModel.isValidDocument()).to(beFalse())
                    expect(viewController.createButton.isEnabled).to(beFalse())

                }
            }

            it("Should implement BaseSiteChangeViewController") {
                expect(viewController).toNot(beNil())
                expect(viewController.changeSiteLocationView).toNot(beNil())
                expect(viewController.changeSiteLocationView.setLocationDelegate).toNot(beNil())
                expect(viewController.changeSiteLocationView.changeButton).toNot(beNil())
                expect(viewController.changeSiteLocationView.siteLabel).toNot(beNil())
            }

            it("didTapCreate") {
                viewController.didTapCreate(self)
                expect(newTokenDelegate.done["didTapCreateToken"]).toEventually(beTrue())
            }

            it("scanButtonTapped") {
                viewController.scanButtonTapped(self)
                expect(newTokenDelegate.done["didTapStartOCRSession"]).toEventually(beTrue())
            }
        }
    }
}
