//
//  TokensViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 07/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class TokenDetailsDelegateMock: TokenDetailsDelegate {
    var done = TestDone()
    func showTokenDetails(model: BodyObject) {
        done["showTokenDetails"] = true
    }
}

class TokensViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        context("TokensViewController") {

            describe("SplashViewControllerSpecs") {

                var viewController: TokensViewController!
                let setLocationDelegate = SetLocationDelegateMock()
                var whistleReachability: WhistleReachabilityMock!
                let switchTabDelegate = SwitchTabDelegateMock()

                beforeEach {
                    viewController = TokensViewController.instantiateFromStoryboard(UIStoryboard.mainStoryboard()!)
                    viewController?.setLocationDelegate = setLocationDelegate
                    viewController?.switchTabDelegate = switchTabDelegate
                    UIApplication.shared.keyWindow!.rootViewController = viewController
                    _ = viewController?.view

                    whistleReachability = WhistleReachabilityMock()
                    viewController.reachabilityObserver.whistleReachability = whistleReachability
                }

                it("Should instantiate from Storyboard") {
                    expect(viewController).toNot(beNil())
                }
                it("UI components should not be nil") {
                    expect(viewController.tableView).toNot(beNil())
                    expect(viewController.noDataTextView).toNot(beNil())
                    expect(viewController.tableRefreshControl).toNot(beNil())
                }

                it("Should implement BaseSiteChangeViewController") {
                    expect(viewController).toNot(beNil())
                    expect(viewController.switchTabDelegate).toNot(beNil())
                    expect(viewController.refreshButton).toNot(beNil())
                    expect(viewController.newTokenButton).toNot(beNil())
                    expect(viewController.changeSiteLocationView).toNot(beNil())
                    expect(viewController.changeSiteLocationView.setLocationDelegate).toNot(beNil())
                    expect(viewController.changeSiteLocationView.changeButton).toNot(beNil())
                    expect(viewController.changeSiteLocationView.siteLabel).toNot(beNil())
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
                        expect(viewController.refreshButton.isEnabled).to(beTrue())
                    }

                    it("not isReachable") {
                        viewController.reachabilityDidChange(isReachable: false)
                        expect(viewController.refreshButton.isEnabled).to(beFalse())
                    }
                }

                it("didTapSelectLocation") {
                    viewController.didTapNewToken(NSObject())
                    expect(switchTabDelegate.done["didChangeTab"]).to(beTrue())
                }
            }

            describe("tableView didSelectRowAt indexPath") {

                var viewController: TokensViewController!
                var tokenDetailsDelegate: TokenDetailsDelegateMock!
                var viewModel: TokensListViewModel!
                var datasource: PersistentDataSourceMock!

                beforeEach {
                    viewController = TokensViewController.instantiateFromStoryboard(UIStoryboard.mainStoryboard()!)
                    tokenDetailsDelegate = TokenDetailsDelegateMock()
                    viewController?.tokenDetailsDelegate = tokenDetailsDelegate
                    datasource = PersistentDataSourceMock()
                    let bodyModel = DataMock.shared.bodyModel!
                    let bodyObj = BodyObject(model: bodyModel)!
                    datasource.listObjects = [bodyObj]
                    viewModel = TokensListViewModel(datasource: datasource)
                    viewController.viewModel = viewModel

                    UIApplication.shared.keyWindow!.rootViewController = viewController
                    _ = viewController?.view
                }

                it("should call showTokenDetails") {
                    let indexPath = IndexPath(row: 0, section: 0)
                    guard let tableView = viewController.tableView else {
                        XCTFail("Failed to load tableView")
                        return
                    }
                    tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
                    expect(tokenDetailsDelegate.done["showTokenDetails"]).to(beTrue())
                }

            }

            describe("TokensTableViewCell") {

                var viewController: TokensViewController!
                let setLocationDelegate = SetLocationDelegateMock()
                var cell: UITableViewCell?
                let bodyObject = BodyObject.randomBody()!

                beforeEach {
                    viewController = TokensViewController.instantiateFromStoryboard(UIStoryboard.mainStoryboard()!)
                    viewController?.setLocationDelegate = setLocationDelegate
                    UIApplication.shared.keyWindow!.rootViewController = viewController
                    _ = viewController?.view

                    cell = viewController.tableView?.dequeueReusableCell(withIdentifier: "TokensTableViewCell")
                    cell?.layoutIfNeeded()
                }

                it("Should instantiate from Storyboard") {
                    expect(cell).toNot(beNil())
                }
                it("UI components should not be nil") {
                    if let tokenCell = cell as? TokensTableViewCell {
                        expect(tokenCell.refLabel).toNot(beNil())
                        expect(tokenCell.regNoLabel).toNot(beNil())
                        expect(tokenCell.titleBackground).toNot(beNil())
                        expect(tokenCell.amountLabel).toNot(beNil())
                        expect(tokenCell.statusLabel).toNot(beNil())
                        expect(tokenCell.statusImageView).toNot(beNil())
                        expect(tokenCell.newNotificationIcon).toNot(beNil())
                    }
                }
                it("Cell UI for bodyObject") {
                    if let tokenCell = cell as? TokensTableViewCell {
                        tokenCell.setupUI(bodyObject: bodyObject)
                        expect(tokenCell.refLabel.text).to(equal(bodyObject.value?.referenceNo))
                        expect(tokenCell.regNoLabel.text).to(equal(bodyObject.value?.vehicleDetails?.regNo))
                        expect(tokenCell.amountLabel.text).to(equal("£" + bodyObject.value!.penaltyAmount))

                        if let token = bodyObject.value,
                            let status = PaymentStatus(rawValue: UInt8(token.paymentStatus)),
                            tokenCell.setChangedStatusUI(status: token.overridden) {
                            if status == .paid {
                                expect(tokenCell.statusLabel.text).to(equal("Paid"))
                                expect(tokenCell.statusImageView.image).toNot(beNil())
                                expect(tokenCell.titleBackground.backgroundColor).to(equal(.dvsaOCRSelected))
                                expect(tokenCell.separatorLine.isHidden).to(beTrue())
                                expect(tokenCell.gestureRecognizers).to(beNil())
                            } else {
                                expect(tokenCell.statusLabel.text).to(equal("Unpaid"))
                                expect(tokenCell.statusImageView.image).to(beNil())
                                expect(tokenCell.titleBackground.backgroundColor).to(equal(.clear))
                                expect(tokenCell.separatorLine.isHidden).toNot(beTrue())
                                expect(tokenCell.gestureRecognizers).to(beNil())
                            }
                        }

                        if let status = SynchStatusType(rawValue: bodyObject.status) {
                            switch status {
                            case .updated:
                                if bodyObject.value?.overridden ?? false {
                                    expect(tokenCell.statusLabel.text).to(equal("Details changed"))
                                    expect(tokenCell.statusImageView.image == UIImage(named: "icon-overriden")).to(beTrue())
                                    expect(tokenCell.titleBackground.backgroundColor).to(equal(.dvsaOrangeBackground))
                                    expect(tokenCell.separatorLine.isHidden).to(beTrue())
                                    expect(tokenCell.gestureRecognizers).toNot(beNil())
                                } else {
                                    expect(tokenCell.statusLabel.textColor).to(equal(.black))
                                    expect(tokenCell.gestureRecognizers).to(beNil())
                                }
                            case .pending:
                                expect(tokenCell.statusLabel.textColor).to(equal(.gray))
                                expect(tokenCell.statusLabel.text).to(equal("Not uploaded"))
                                expect(tokenCell.statusImageView.image).toNot(beNil())
                                expect(tokenCell.gestureRecognizers).to(beNil())
                            case .conflicted:
                                expect(tokenCell.statusLabel.textColor).to(equal(.dvsaRed))
                                expect(tokenCell.statusLabel.text).to(equal("Data conflict"))
                                expect(tokenCell.statusImageView.image).to(beNil())
                                expect(tokenCell.gestureRecognizers).to(beNil())
                            }
                        }

                        tokenCell.setupCellUI(titleColor: .dvsaPinkBackground,
                                              statusText: "Test1",
                                              statusTextColor: .dvsaRed,
                                              statusImage: nil,
                                              hideSeparatorLine: true)
                        expect(tokenCell.titleBackground.backgroundColor).to(equal(.dvsaPinkBackground))
                        expect(tokenCell.statusLabel.textColor).to(equal(.dvsaRed))
                        expect(tokenCell.statusLabel.text).to(equal("Test1"))
                        expect(tokenCell.statusImageView.image).to(beNil())
                        expect(tokenCell.gestureRecognizers).to(beNil())
                        expect(tokenCell.separatorLine.isHidden).to(beTrue())
                    }
                }
            }
        }
    }
}
