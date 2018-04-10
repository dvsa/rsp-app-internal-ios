//
//  BodyObjectListViewModelSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 06/04/2018.
//Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class BodyObjectListViewModelSpecs: QuickSpec {
    override func spec() {
        describe("DriverNotificationViewModelSpecs") {

            var datasourceMock: PersistentDataSourceMock!
            var viewModel: BodyObjectListViewModel!
            var viewModelFiltered: BodyObjectListViewModel!

            beforeEach {
                datasourceMock = PersistentDataSourceMock()

                let body1 = BodyObject.randomBody()!
                let body2 = BodyObject.randomBody()!
                body2.enabled = false

                datasourceMock.listObjects = [body1, body2]
                viewModel = BodyObjectListViewModel(datasource: datasourceMock)
                viewModelFiltered = BodyObjectListViewModel(datasource: datasourceMock, filterOptions: { (body) -> Bool in
                    return body.enabled == false
                })
            }

            context("init") {
                it("should not be nil") {
                    expect(viewModel).toNot(beNil())
                    expect(viewModel.count()).to(equal(2))
                }
            }

            context("init") {
                it("should not be nil") {
                    expect(viewModelFiltered).toNot(beNil())
                    expect(viewModelFiltered.count()).to(equal(1))
                }
            }
        }
    }
}
