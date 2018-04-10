//
//  TokensListViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 08/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class TokensListViewModelSpecs: QuickSpec {

    override func spec() {
        let datasourceMock = PersistentDataSourceMock()
        let viewModel = TokensListViewModel(datasource: datasourceMock)

        context("init with datasource") {
            it("should not be nil") {
                expect(viewModel).toNot(beNil())
            }
        }

        context("test update visibility of notification") {
            try? viewModel.datasource.insert(item: BodyObject.randomBody()!)
            it("test update visibility") {
                expect(viewModel.datasource.item(for: "mock")?.hideNotification).to(beFalse())
                try? viewModel.datasource.hideNotification(for: "mock")
                expect(viewModel.datasource.item(for: "mock")?.hideNotification).to(beTrue())
            }
        }
    }

}
