//
//  LoggerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 05/04/2018.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class LoggerSpecs: QuickSpec {
    override func spec() {
        describe("Logger") {

            context("logFiles") {
                it("should return log list") {
                    let url = cacheDirectory().appendingPathComponent(kLogFileName + "000.txt")
                    let logData = "test".data(using: String.Encoding.utf8)
                    try? logData?.write(to: url)
                    expect(logFiles()?.contains(url)).to(beTrue())
                }
            }
        }
    }
}
