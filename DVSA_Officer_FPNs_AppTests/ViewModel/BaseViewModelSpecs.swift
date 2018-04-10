//
//  BaseViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class BaseViewModelDelegateMock: ViewModelLoaderDelegate {

    var loaded = false
    var failed = false

    func viewModelDidLoad(result: ViewModelLoadResult) {
        switch result {
        case .success:
            loaded = true
        case .error:
            failed = true
        }
    }
}

class BaseViewModelSpecs: QuickSpec {

    override func spec() {

        describe("BaseViewModel") {
            it("Should call the delegate viewModelDidLoad") {

                let delegate = BaseViewModelDelegateMock()
                let bm = BaseViewModel(delegate: delegate)
                bm.loadData()
                expect(delegate.loaded).to(be(true))
            }
        }
    }
}
