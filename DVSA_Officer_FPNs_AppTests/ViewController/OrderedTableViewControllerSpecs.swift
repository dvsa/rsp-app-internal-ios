//
//  OrderedTableViewControllerSpecs.swift
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

class OrderedTableViewControllerDelegateMock: ListTableViewControllerDelegate {

    var done = TestDone()

    func didSelect(key: Int) {
        done["didSelect"] = true
    }

    func refreshData(completion: @escaping (Bool) -> Void) {
        done["refreshData"] = true
        completion(true)
    }
}

class OrderedTableViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("OrderedTableViewController") {

            let site = SiteObject(model: DataMock.shared.siteModel!)!
            var viewModel: ListViewModel<SiteObjectList>!
            var configureTable: ConfigureOrderedTable!
            var delegateMock: OrderedTableViewControllerDelegateMock!

            beforeEach {
                delegateMock = OrderedTableViewControllerDelegateMock()
                let model = SiteObjectList()
                model.items = [site]
                viewModel = ListViewModel<SiteObjectList>(model: model)
                configureTable = ConfigureOrderedTable(styleTable: UITableViewStyle.plain,
                                                       title: "Site Location",
                                                       delegate: delegateMock,
                                                       collationStringSelector: #selector(getter: SiteObject.name),
                                                       cellStyle: UITableViewCellStyle.default,
                                                       reuseIdentifier: "SiteListTableViewCell")
            }

            it("Should call populateCell") {

                weak var populateExpectation = self.expectation(description: "populateExpectation")
                let vc = OrderedTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                    guard let expectation = populateExpectation else {
                        return
                    }
                    expectation.fulfill()
                    populateExpectation = nil
                }

                UIApplication.shared.keyWindow!.rootViewController = vc
                _ = vc.view

                self.waitForExpectations(timeout: 10) { (_) in

                }
                let index = IndexPath(item: 0, section: 0)
                let cell = vc.tableView(vc.tableView, cellForRowAt: index)
                expect(cell).toNot(beNil())
                expect(cell.accessibilityIdentifier).toNot(beNil())
            }

            it("Should have 27 section") {

                let vc = OrderedTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                expect(vc.tableView.numberOfSections).to(equal(27))

                let sections = vc.sections(viewModel: viewModel)
                expect(sections.count).to(equal(27))
            }

            it("Should have 1 rows") {

                let vc = OrderedTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                expect(vc.tableView.numberOfRows(inSection: 0)).to(equal(1))
            }

            it("Should call the delegate on ") {
                let vc = OrderedTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                let index = IndexPath(item: 0, section: 0)
                vc.tableView(vc.tableView, didSelectRowAt: index)

                let delegate = configureTable.delegate as? OrderedTableViewControllerDelegateMock
                expect(delegate).toNot(beNil())
                expect(delegate?.done["didSelect"]).toEventually(be(true))
            }

            it("handleRefresh") {

                let vc = OrderedTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                _ = vc.view
                let control = UIRefreshControl(frame: CGRect.zero)
                vc.handleRefresh(refreshControl: control)
                expect(delegateMock.done["refreshData"]).to(beTrue())
            }
        }
    }
}
