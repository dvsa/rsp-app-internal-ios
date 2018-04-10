//
//  OCRCameraSessionSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 19/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class OCRCameraSessionSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("OCRCameraSession") {

            let flowConfigure = FlowConfigure(window: nil, navigationController: UINavigationController(), parent: nil)
            let cameraVC = OCRCameraSessionViewController.instantiate(delegate: NewTokenFlowController(configure: flowConfigure),
                                                                      viewModel: OCRCameraSessionViewModel(model: NewTokenModel(value: nil)))
            cameraVC.loadViewIfNeeded()

            context("init") {
                it("should not be nil") {
                    expect(cameraVC).toNot(beNil())
                }
                it("viewModel should not be nil") {
                    expect(cameraVC.viewModel).toNot(beNil())
                }
            }

            context("UI components") {
                it("Range finder view should not be nil") {
                    expect(cameraVC.rangeFinderView).toNot(beNil())
                }
                it("Range finder focus should not be nil") {
                    expect(cameraVC.rangeFinderFocusView).toNot(beNil())
                }
                it("Scan button should not be nil") {
                    expect(cameraVC.scanButton).toNot(beNil())
                    expect(cameraVC.scanButton.accessibilityIdentifier).to(equal("scanButton"))
                    expect(cameraVC.scanButton.isAccessibilityElement).to(beTrue())
                    expect(cameraVC.scanButton.isEnabled).to(beTrue())
                }
                it("Flash button should not be nil") {
                    expect(cameraVC.flashButton).toNot(beNil())
                    expect(cameraVC.flashButton.accessibilityIdentifier).to(equal("flashButton"))
                    expect(cameraVC.flashButton.isAccessibilityElement).to(beTrue())
                    expect(cameraVC.flashButton.isEnabled).to(beTrue())
                }
                it("Helper should not be nil") {
                    expect(cameraVC.arrowView).toNot(beNil())
                    expect(cameraVC.helperLabel).toNot(beNil())
                    expect(cameraVC.arrowView.isHidden).to(beTrue())
                    expect(cameraVC.helperLabel.isHidden).to(beTrue())
                    expect(cameraVC.arrowView.accessibilityIdentifier).to(equal("arrowView"))
                    expect(cameraVC.helperLabel.accessibilityIdentifier).to(equal("helperLabel"))
                    expect(cameraVC.arrowView.isAccessibilityElement).to(beTrue())
                    expect(cameraVC.helperLabel.isAccessibilityElement).to(beTrue())
                }
            }

            context("session") {
                it("AVCaputure session should not be nil") {
                    expect(cameraVC.session).toNot(beNil())
                }
            }

            context("table view") {
                it("table view should not be nil") {
                    expect(cameraVC.tableView).toNot(beNil())
                }
                it("table view number of sections") {
                    expect(cameraVC.tableView.numberOfSections).to(equal(1))
                }
                it("table view number of rows") {
                    expect(cameraVC.tableView.numberOfRows(inSection: 0)).to(equal(4))
                }
                it("table view default selection") {
                    expect(cameraVC.tableView.indexPathForSelectedRow).to(equal(IndexPath(row: 0, section: 0)))
                }
                it("table view cell type") {
                    expect(cameraVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) is OCRCameraSessionTableCell).to(beTrue())
                    expect(cameraVC.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) is OCRCameraSessionTableCell).to(beTrue())
                    expect(cameraVC.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) is OCRCameraSessionTableCell).to(beTrue())
                    expect(cameraVC.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) is OCRCameraSessionTableCell).to(beTrue())
                }

                describe("OCRCameraSessionTableCell cells") {
                    let firstCell = cameraVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OCRCameraSessionTableCell
                    let secondCell = cameraVC.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? OCRCameraSessionTableCell
                    let thirdCell = cameraVC.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? OCRCameraSessionTableCell
                    let fourthCell = cameraVC.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? OCRCameraSessionTableCell

                    it("backgound color of cells") {
                        expect(firstCell?.labelBackground.backgroundColor).to(equal(UIColor.dvsaOCRSelected))
                        expect(secondCell?.labelBackground.backgroundColor).to(equal(UIColor.dvsaOCRNormal))
                    }
                    it("cell title text") {
                        expect(firstCell?.titleLabel.text).to(equal("Reference: "))
                        expect(secondCell?.titleLabel.text).to(equal("Vehicle reg: "))
                        expect(thirdCell?.titleLabel.text).to(equal("Date: "))
                        expect(fourthCell?.titleLabel.text).to(equal("Amount (£): "))
                    }
                    it("cell selection style") {
                        expect(firstCell?.selectionStyle).to(equal(UITableViewCellSelectionStyle.none))
                        expect(secondCell?.selectionStyle).to(equal(UITableViewCellSelectionStyle.none))
                        expect(thirdCell?.selectionStyle).to(equal(UITableViewCellSelectionStyle.none))
                        expect(fourthCell?.selectionStyle).to(equal(UITableViewCellSelectionStyle.none))
                    }
                    it("cell set text") {
                        firstCell?.setValueLabel(text: "Changed")
                        expect(firstCell?.valueLabel.text).to(equal("Changed"))
                    }
                }

                describe("OCRConfirmationResultView") {
                    it("confirmation view should not be nil") {
                        expect(cameraVC.resultView).toNot(beNil())
                    }
                    it("confirmation UI components") {
                        expect(cameraVC.resultView.titleLabel).toNot(beNil())
                        expect(cameraVC.resultView.valueLabel).toNot(beNil())
                        expect(cameraVC.resultView.retryButton).toNot(beNil())
                        expect(cameraVC.resultView.confirmButton).toNot(beNil())
                    }
                    it("test setup") {
                        let index = IndexPath(row: 0, section: 0)
                        cameraVC.resultView.setupContents(title: "title",
                                                          value: "value",
                                                          sessionDelegate: cameraVC,
                                                          image: UIImage(),
                                                          indexPath: index)
                        expect(cameraVC.resultView.titleLabel.text).to(equal("title"))
                        expect(cameraVC.resultView.valueLabel.text).to(equal("value"))
                        expect(cameraVC.resultView.resultIndexPath).to(equal(index))
                    }
                }

            }

        }
    }
}
