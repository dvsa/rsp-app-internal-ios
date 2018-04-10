//
//  SetLocationViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 19/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class SetLocationViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("SetLocationViewController") {

            let storyboard = UIStoryboard.mainStoryboard()!
            var viewController: SetLocationViewController!
            var setLocationDelegateMock: SetLocationDelegateMock!
            var viewModel: UserPreferencesViewModel?
            var preferencesMock: PreferencesDataSourceMock!
            var site: SiteObject!

            beforeEach {
                preferencesMock = PreferencesDataSourceMock()
                viewModel = UserPreferencesViewModel(datasource: preferencesMock)
                site = SiteObject()

                viewController = SetLocationViewController.instantiateFromStoryboard(storyboard)
                UIApplication.shared.keyWindow!.rootViewController = viewController
                setLocationDelegateMock = SetLocationDelegateMock()
                viewController.setLocationDelegate = setLocationDelegateMock
                _ = viewController.loadView()
                viewController.viewModel = viewModel

            }

            it("Should instantiate from Storyboard") {

                expect(viewController).toNot(beNil())

                expect(viewController.selectLabel).toNot(beNil())
                expect(viewController.selectLocationLabel).toNot(beNil())
                expect(viewController.confirmLocationButton).toNot(beNil())
                expect(viewController.roundedView).toNot(beNil())
                expect(viewController.locationTypeSegmented).toNot(beNil())
                expect(viewController.locationTypeLabel).toNot(beNil())
                expect(viewController.mobileAddressLabel).toNot(beNil())
                expect(viewController.mobileLocationTextField).toNot(beNil())
                expect(viewController.mobileAddressStackView).toNot(beNil())

            }

            it("didTapSelectLocation") {
                viewController.didTapSelectLocation(NSObject())
                expect(setLocationDelegateMock.done["didTapChangeLocation"]).to(beTrue())
            }

            it("didChangeLocationType should update model") {

                viewController.locationTypeSegmented.selectedSegmentIndex = 0
                viewController.didChangeLocationType(NSObject())
                expect(viewModel?.isMobile).toNot(beTrue())

                viewController.locationTypeSegmented.selectedSegmentIndex = 1
                viewController.didChangeLocationType(NSObject())
                expect(viewModel?.isMobile).to(beTrue())
            }

            it("mobileLocationTextFieldChanged") {

                site.name = "Area 1"
                site.code = -1
                viewModel?.isMobile = true
                viewModel?.temporaryMobileLocation = nil
                viewController.mobileLocationTextField.text = "My Address"
                viewController.mobileLocationTextFieldChanged(NSObject())
                expect(viewController?.mobileLocationTextField.text).to(equal("My Address"))
                expect(viewController?.confirmLocationButton.isHidden).to(beTrue())

                site.name = "Area 1"
                site.code = -1
                viewModel?.isMobile = true
                viewModel?.temporaryMobileLocation = site
                viewController.mobileLocationTextField.text = "My Address"
                viewController.mobileLocationTextFieldChanged(NSObject())
                expect(viewController?.mobileLocationTextField.text).to(equal("My Address"))
                expect(viewController?.confirmLocationButton.isHidden).to(beFalse())

                site.name = "Area 1"
                site.code = -1
                viewModel?.isMobile = true
                viewModel?.temporaryMobileLocation = site
                viewController.mobileLocationTextField.text = ""
                viewController.mobileLocationTextFieldChanged(NSObject())
                expect(viewController?.mobileLocationTextField.text).to(equal(""))
                expect(viewController?.confirmLocationButton.isHidden).to(beTrue())

                site.name = "Area 1"
                site.code = -1
                viewModel?.isMobile = true
                viewModel?.temporaryMobileLocation = site
                viewController.mobileLocationTextField.text = nil
                viewController.mobileLocationTextFieldChanged(NSObject())
                expect(viewController?.mobileLocationTextField.text).to(equal(""))
                expect(viewController?.confirmLocationButton.isHidden).to(beTrue())

            }

            context("updateUI") {

                context("isMobile") {

                    beforeEach {
                        site.name = "Mobile"
                        site.code = -1
                        viewController.viewModel?.isMobile = true
                        viewController.viewModel?.temporaryMobileAddress = "My Address"
                        viewController.viewModel?.temporaryMobileLocation = site
                    }

                    it("enable mobile ui") {
                        viewController.updateUI()
                        expect(viewController.locationTypeLabel.text).to(equal("Enforcement area"))
                        expect(viewController.mobileLocationTextField.text).to(equal("My Address"))

                        expect(viewController.selectLocationLabel.text).to(equal("Mobile"))
                        expect(viewController.mobileAddressStackView.isHidden).to(beFalse())
                        expect(viewController.confirmLocationButton.isHidden).to(beFalse())

                        viewController.viewModel?.temporaryMobileAddress = nil
                        viewController.updateUI()
                        expect(viewController.locationTypeLabel.text).to(equal("Enforcement area"))
                        expect(viewController.mobileLocationTextField.text).to(equal(""))

                        expect(viewController.selectLocationLabel.text).to(equal("Mobile"))
                        expect(viewController.mobileAddressStackView.isHidden).to(beFalse())
                        expect(viewController.confirmLocationButton.isHidden).to(beTrue())
                    }
                }

                context("not isMobile") {

                    beforeEach {
                        site.name = "Site"
                        site.code = 1
                        viewController.viewModel?.isMobile = false
                        viewController.viewModel?.temporarySiteLocation = site
                    }

                    it("enable mobile ui") {
                        viewController.updateUI()
                        expect(viewController.locationTypeLabel.text).to(equal("Fixed site"))

                        expect(viewController.selectLocationLabel.text).to(equal("Site"))
                        expect(viewController.mobileAddressStackView.isHidden).to(beTrue())
                        expect(viewController.confirmLocationButton.isHidden).to(beFalse())

                        viewController.viewModel?.temporarySiteLocation = nil
                        viewController.updateUI()
                        expect(viewController.locationTypeLabel.text).to(equal("Fixed site"))

                        expect(viewController.selectLocationLabel.text).to(equal("Site Location"))
                        expect(viewController.mobileAddressStackView.isHidden).to(beTrue())
                        expect(viewController.confirmLocationButton.isHidden).to(beTrue())
                    }
                }

            }

            context("didTapConfirmLocation") {

                it("when isMobile") {
                    site.name = "Area 1"
                    site.code = -1
                    viewModel?.isMobile = true
                    viewModel?.temporaryMobileLocation = site
                    viewModel?.temporaryMobileAddress = "My mobile address"

                    viewController.didTapConfirmLocation(NSObject())
                    expect(setLocationDelegateMock.done["didTapConfirmLocation"]).toNot(beTrue())
                    expect(setLocationDelegateMock.site?.code).to(equal(-1))
                    expect(setLocationDelegateMock.site?.name).to(equal("Area 1"))
                    expect(setLocationDelegateMock.mobileAddress).to(equal("My mobile address"))
                }

                it("when not isMobile") {
                    site.name = "Site 1"
                    site.code = 1
                    viewModel?.isMobile = false
                    viewModel?.temporarySiteLocation = site
                    viewModel?.temporaryMobileAddress = "My mobile address"

                    viewController.didTapConfirmLocation(NSObject())
                    expect(setLocationDelegateMock.done["didTapConfirmLocation"]).toNot(beTrue())
                    expect(setLocationDelegateMock.site?.code).to(equal(1))
                    expect(setLocationDelegateMock.site?.name).to(equal("Site 1"))
                    expect(setLocationDelegateMock.mobileAddress).to(beNil())
                }
            }
        }
    }
}
