//
//  DataSourceSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/04/2018.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class DataSourceSpecs: QuickSpec {
    override func spec() {
        describe("DataSourceError") {
            context("LocalizedError") {
                it("should set strings") {
                    let error = DataSourceError.duplicateKey
                    expect(error.failureReason).to(equal("A token already exists for this reference number."))
                    expect(error.errorDescription).to(equal("Duplicate"))
                }
            }
        }
    }
}
