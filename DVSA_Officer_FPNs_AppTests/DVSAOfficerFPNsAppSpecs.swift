//
//  DVSA_Officer_FPNs_AppSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 05/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class DVSAOfficerFPNsAppSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("ConfigEnvironment") {
            it("Should have 5 elements") {

                guard let dev = ConfigEnvironment(rawValue: "DEV") else {
                    XCTFail("Failed to load dev ConfigEnvironment")
                    return
                }
                switch dev {
                case .dev:
                    XCTAssert(true)
                case .qa:
                    XCTAssert(true)
                case .uat:
                    XCTAssert(true)
                case .perf:
                    XCTAssert(true)
                case .prod:
                    XCTAssert(true)
                }
            }

            it("Should decode environment") {

                guard let dev = ConfigEnvironment(rawValue: "DEV") else {
                    XCTFail("Failed to load dev ConfigEnvironment")
                    return
                }
                expect(dev).to(equal(ConfigEnvironment.dev))

                guard let qa = ConfigEnvironment(rawValue: "QA") else {
                    XCTFail("Failed to load qa ConfigEnvironment")
                    return
                }
                expect(qa).to(equal(ConfigEnvironment.qa))

                guard let uat = ConfigEnvironment(rawValue: "UAT") else {
                    XCTFail("Failed to load uat ConfigEnvironment")
                    return
                }
                expect(uat).to(equal(ConfigEnvironment.uat))

                guard let perf = ConfigEnvironment(rawValue: "PERF") else {
                    XCTFail("Failed to load perf ConfigEnvironment")
                    return
                }
                expect(perf).to(equal(ConfigEnvironment.perf))

                guard let prod = ConfigEnvironment(rawValue: "PROD") else {
                    XCTFail("Failed to load prod ConfigEnvironment")
                    return
                }
                expect(prod).to(equal(ConfigEnvironment.prod))

            }
        }

        describe("DVSA_Officer_FPNs_App ConfigModel") {
            it("Should have the environment") {
                expect(ConfigModel.environment().rawValue).toNot(equal(""))
            }

            it("Should have the bundleIdentifier") {
                expect(ConfigModel.bundleIdentifier()).toNot(equal(""))
                expect(ConfigModel.bundleIdentifier()).toNot(beNil())
            }

            it("Should contain the Environment in the BundleIdentifier") {

                let env = ConfigModel.environment()
                let bundleIdentifier = ConfigModel.bundleIdentifier()

                let envValue = env.rawValue as String

                switch env {
                case .prod:
                    expect(bundleIdentifier?.range(of: envValue)).to(beNil())
                default:
                    expect(bundleIdentifier?.range(of: envValue)).toNot(beNil())
                }
            }

            it("Should have all the ItemModel") {

                let totalProperties = 5

                let configModel = ConfigModel()
                let dictionary = configModel.dictionary()

                expect(configModel.all().count).to(equal(totalProperties))
                expect(dictionary.count).to(equal(totalProperties))

                expect(dictionary["environment"]).toNot(beNil())
                expect(dictionary["bundleIdentifier"]).toNot(beNil())

                expect(dictionary["kAdalRedirectURI"]).toNot(beNil())
                expect(dictionary["kBundleUrlSchema"]).toNot(beNil())
                expect(dictionary["kSNSPlatformApplicationArn"]).toNot(beNil())

                expect(dictionary["kAdalRedirectURI"]).toNot(equal(""))
                expect(dictionary["kBundleUrlSchema"]).toNot(equal(""))
                expect(dictionary["kSNSPlatformApplicationArn"]).toNot(equal(""))
            }

            it("Should retrieve item by name") {

                let configModel = ConfigModel()
                let dictionary = configModel.dictionary()

                let item = configModel.item(for: "environment")
                expect(item?.value).to(equal(dictionary["environment"]))
            }

            it("Should retrieve item by index") {

                let configModel = ConfigModel()

                let item = configModel.item(at: 0)
                expect(item).toNot(beNil())
            }
        }
    }
}
