//
//  ListViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class ListTableViewControllerDelegateMock: ListTableViewControllerDelegate {

    var done = TestDone()

    func didSelect(key: Int) {
        done["didSelect"] = true
    }

    func refreshData(completion: @escaping (Bool) -> Void) {

        done["refreshData"] = true
        completion(true)
    }

}

class BaseModel: Model {

}

class BaseListModel: ListModel {

    typealias Model = BaseModel

    private var model: [BaseModel]

    init(model: [BaseModel]) {
        self.model = model
    }

    func all() -> [BaseModel] {
        return model
    }

    func item(at index: Int) -> BaseModel? {
        return model[index]
    }
}

class ListViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("ListViewController") {

            let site = SiteObject()
            site.name = "A"
            site.code = -1

            let site2 = SiteObject()
            site2.name = "A"
            site2.code = -1

            let model = SiteObjectList()
            model.items = [site, site2]
            let viewModel = ListViewModel<SiteObjectList>(model: model)
            var configureTable: ConfigureTable!
            var delegateMock: ListTableViewControllerDelegateMock!

            beforeEach {
                delegateMock = ListTableViewControllerDelegateMock()
                configureTable = ConfigureTable(styleTable: .plain,
                                                    title: "List of Base Model",
                                                    delegate: delegateMock,
                                                    cellStyle: .default, reuseIdentifier: "ListTableViewControllerCell")
            }

            it("Should call populateCell") {

                weak var populateExpectation = self.expectation(description: "populateExpectation")
                let vc = ListTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

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

            it("Should have 1 section") {

                let vc = ListTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                expect(vc.tableView.numberOfSections).to(equal(1))
            }

            it("Should have 2 rows") {

                let vc = ListTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                expect(vc.tableView.numberOfRows(inSection: 0)).to(equal(2))
            }

            it("Should call the delegate on ") {
                let vc = ListTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                let index = IndexPath(item: 0, section: 0)
                vc.tableView(vc.tableView, didSelectRowAt: index)
                expect(delegateMock).toNot(beNil())
                expect(delegateMock?.done["didSelect"]).toEventually(beTrue())
            }

            it("handleRefresh") {

                let vc = ListTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { _, _ in

                }
                _ = vc.view
                let control = UIRefreshControl(frame: CGRect.zero)
                vc.handleRefresh(refreshControl: control)
                expect(delegateMock.done["refreshData"]).to(beTrue())
            }
        }
    }
}
