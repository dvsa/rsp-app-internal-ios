//
//  NewTokenFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 09/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit
import Compass
@testable import DVSA_Officer_FPNs_App

class NewTokenFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {

        describe("NewTokenFlowController") {

            let navigationController = UINavigationController()
            let flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)
            var newTokenFlowController: NewTokenFlowController?

            beforeEach {
                newTokenFlowController = NewTokenFlowController(configure: flowConfigure)
                newTokenFlowController?.datasource = PersistentDataSourceMock()
                newTokenFlowController?.preferences = PreferencesDataSourceMock()
            }

            context("init") {
                it("should not be nil") {
                    expect(newTokenFlowController).toNot(beNil())
                }
                it("should set configure as main") {
                    expect(newTokenFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("when start") {
                beforeEach {
                    newTokenFlowController?.start()
                }
                it("should not set window") {
                    expect(newTokenFlowController?.configure.window).to(beNil())
                }
                it("should set navigation") {
                    expect(newTokenFlowController?.configure.navigationController).toNot(beNil())
                    expect(newTokenFlowController?.configure.navigationController?.viewControllers).toNot(beNil())
                }
                it("should set viewController") {
                    expect(newTokenFlowController?.viewController).toNot(beNil())
                    expect(newTokenFlowController?.viewController?.newTokenDelegate).toNot(beNil())
                    expect(newTokenFlowController?.viewController?.setLocationDelegate).toNot(beNil())
                    expect(newTokenFlowController?.viewController?.viewModel).toNot(beNil())
                }
            }

            context("SetLocationDelegate") {
                it("didConfirmLocation") {
                    expect(newTokenFlowController?.childFlow).to(beNil())
                    newTokenFlowController?.didTapChangeLocation()
                    expect(newTokenFlowController?.childFlow).toNot(beNil())
                    newTokenFlowController?.didConfirmLocation(site: SiteObject(), mobileAddress: nil)
                    expect(newTokenFlowController?.childFlow).to(beNil())
                }
                it("didTapChangeLocation") {
                    expect(newTokenFlowController?.childFlow).to(beNil())
                    newTokenFlowController?.didTapChangeLocation()
                    expect(newTokenFlowController?.childFlow).toNot(beNil())
                    let setLocationFlowController = newTokenFlowController?.childFlow as? SetLocationFlowController
                    expect(setLocationFlowController).toNot(beNil())
                    expect(setLocationFlowController?.preferences).toNot(beNil())
                }
            }

            context("NewTokenDelegate") {
                beforeEach {
                    newTokenFlowController?.start()
                }

                context("didTapCreateToken") {
                    it("should not be nil with model") {

                        let model = newTokenFlowController?.viewController?.viewModel.model
                        model?.dateTime = Date()
                        model?.referenceNo = "1234-1-567890-IM"
                        model?.penaltyAmount = "66"
                        model?.vehicleRegNo = "LD12HHH"
                        model?.penaltyType = PenaltyType.immobilization

                        expect(newTokenFlowController?.childFlow).to(beNil())
                        newTokenFlowController?.didTapCreateToken()
                        expect(newTokenFlowController?.childFlow).toNot(beNil())
                        let newTokenDetailsFlowController = newTokenFlowController?.childFlow as? NewTokenDetailsFlowController
                        expect(newTokenDetailsFlowController).toNot(beNil())
                    }

                    it("should not be nil without model") {
                        expect(newTokenFlowController?.childFlow).to(beNil())
                        newTokenFlowController?.didTapCreateToken()
                        expect(newTokenFlowController?.childFlow).to(beNil())
                    }
                }

                context("didTapStartOCRSession") {
                    it("should show OCR") {
                        newTokenFlowController?.didTapStartOCRSession()
                        expect(newTokenFlowController?.configure.navigationController).toNot(beNil())
                        let modalVC = newTokenFlowController?.modalVC
                        expect(modalVC).toNot(beNil())
                    }
                }

                context("CreateTokenDetailsDelegate") {
                    it("didTapDone") {

                        let model = newTokenFlowController?.viewController?.viewModel.model
                        model?.dateTime = Date()
                        model?.referenceNo = "1234-1-567890-IM"
                        model?.penaltyAmount = "66"
                        model?.vehicleRegNo = "LD12HHH"
                        model?.penaltyType = PenaltyType.immobilization

                        newTokenFlowController?.didTapDone()

                        let updatedModel = newTokenFlowController?.viewController?.viewModel.model

                        expect(updatedModel?.referenceNo).to(equal(""))
                        expect(updatedModel?.penaltyAmount).to(equal(""))
                        expect(updatedModel?.vehicleRegNo).to(equal(""))
                        expect(updatedModel?.dateTime).to(beNil())
                    }
                }

                context("OCRSessionDelegate") {

                    beforeEach {
                        newTokenFlowController?.didTapStartOCRSession()
                        expect(newTokenFlowController?.configure.navigationController).toNot(beNil())
                        let modalVC = newTokenFlowController?.modalVC
                        expect(modalVC).toNot(beNil())

                        let model = newTokenFlowController?.viewController?.viewModel.model
                        model?.dateTime = Date()
                        model?.referenceNo = "1234-1-567890-IM"
                        model?.penaltyAmount = "66"
                        model?.vehicleRegNo = "LD12HHH"
                        model?.penaltyType = PenaltyType.immobilization
                    }

                    it("didTapCancelOCRSession") {
                        newTokenFlowController?.didTapCancelOCRSession()
                        let updatedModel = newTokenFlowController?.viewController?.viewModel.model
                        expect(updatedModel?.referenceNo).to(equal("1234-1-567890-IM"))
                        expect(updatedModel?.penaltyAmount).to(equal("66"))
                        expect(updatedModel?.vehicleRegNo).to(equal("LD12HHH"))
                    }

                    it("didTapDoneOCRSession") {

                        let model = NewTokenModel(value: nil)
                        model.dateTime = Date()
                        model.referenceNo = "2334-1-567890-IM"
                        model.penaltyAmount = "99"
                        model.vehicleRegNo = "LD12HHH"
                        model.penaltyType = PenaltyType.immobilization

                        _ = newTokenFlowController?.viewController?.view

                        newTokenFlowController?.didTapDoneOCRSession(model: model)
                        let updatedModel = newTokenFlowController?.viewController?.viewModel.model

                        expect(updatedModel?.referenceNo).to(equal("2334-1-567890-IM"))
                        expect(updatedModel?.penaltyAmount).to(equal("99"))
                        expect(updatedModel?.vehicleRegNo).to(equal("LD12HHH"))

                        expect(newTokenFlowController?.viewController?.refNumberTextField.text).to(equal("2334"))
                        expect(newTokenFlowController?.viewController?.imReference1TextField.text).to(equal("1"))
                        expect(newTokenFlowController?.viewController?.imReference2TextField.text).to(equal("567890"))
                        expect(newTokenFlowController?.viewController?.vehicleRegTextField.text).to(equal("LD12HHH"))
                        expect(newTokenFlowController?.viewController?.penaltyAmountTextField.text).to(equal("99"))
                        let segmentCtrl = newTokenFlowController?.viewController?.penaltyTypeSegmentedControl
                        expect(segmentCtrl?.selectedSegmentIndex).to(equal(Int(PenaltyType.immobilization.rawValue)))
                    }
                }
            }
        }
    }
}
