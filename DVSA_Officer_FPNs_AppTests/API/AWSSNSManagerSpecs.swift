//
//  AWSSNSManagerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 12/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import Foundation

@testable import DVSA_Officer_FPNs_App

class AWSSNSManagerSpecs: QuickSpec {

    //swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("AWSSNSManager") {

            let sharedManager = AWSSNSManager.shared
            var application: UIApplication!
            var tokenDataMock: Data!
            let bytes: [UInt8] = [213, 85, 229, 132, 233, 178, 77, 130, 17, 114, 92, 11, 255, 171, 30, 207, 195, 129, 2, 171, 231, 219, 101, 80, 131, 134, 214, 229, 20, 110, 248, 1]
            beforeEach {
                application = UIApplication.shared
                tokenDataMock = Data(bytes)
            }
            context("shared") {
                it("should not be nil") {
                    expect(sharedManager).toNot(beNil())
                }

                it("should setup keychain") {
                    expect(sharedManager.keyChain).toNot(beNil())
                }

                it("should setup token") {
                    sharedManager.application(application, didRegisterForRemoteNotificationsWithDeviceToken: tokenDataMock)
                    let token = sharedManager.keyChain[AWSSNSManager.Key.deviceToken]
                    expect(token).to(equal("d555e584e9b24d8211725c0bffab1ecfc38102abe7db65508386d6e5146ef801"))
                }

                it("should setup token") {
                    let error = NSError(domain: "demo", code: 10, userInfo: [:])
                    sharedManager.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
                    let token = sharedManager.keyChain[AWSSNSManager.Key.deviceToken]
                    expect(token).to(beNil())
                }
            }

            context("helpers") {
                it("subscribeTopicRequest") {
                    let value = sharedManager.subscribeTopicRequest(endpointArn: "test")
                    expect(value).toNot(beNil())
                }
                it("unsubscribeTopicRequest") {
                    let value = sharedManager.unsubscribeTopicRequest(subscriptionArn: "test")
                    expect(value).toNot(beNil())
                }
                it("confirmSubscritpionRequest") {
                    let value = sharedManager.confirmSubscritpionRequest(token: "test")
                    expect(value).toNot(beNil())
                }
            }

            context("properties") {
                it("subscriptionArn") {
                    sharedManager.subscriptionArn = "subscriptionArn1"
                    var value = UserDefaults.standard.string(forKey: AWSSNSManager.Key.subscriptionArn)
                    expect(value).to(equal("subscriptionArn1"))

                    sharedManager.subscriptionArn = nil
                    value = UserDefaults.standard.string(forKey: AWSSNSManager.Key.subscriptionArn)
                    expect(value).to(beNil())
                }

                it("endpointArn") {
                    sharedManager.endpointArn = "endpointArn1"
                    var value = UserDefaults.standard.string(forKey: AWSSNSManager.Key.endpointArn)
                    expect(value).to(equal("endpointArn1"))

                    sharedManager.endpointArn = nil
                    value = UserDefaults.standard.string(forKey: AWSSNSManager.Key.endpointArn)
                    expect(value).to(beNil())
                }
            }
        }
    }
}
