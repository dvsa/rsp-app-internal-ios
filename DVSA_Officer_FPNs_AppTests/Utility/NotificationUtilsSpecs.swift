//
//  NotificationUtilsSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 08/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class NotificationUtilsSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("NotificationUtils") {
            let userInfo: [AnyHashable: Any] = ["site": 7,
                                                "refNo": "ref001",
                                                "regNo": "LD18 AAB",
                                                "type": "FPN",
                                                "amount": 250,
                                                "status": "PAID",
                                                "offset": 1520590707.223]

            let silentUserInfo: [AnyHashable: Any] = ["site": 0,
                                                      "offset": 1520590707.223]

            let invalidSilentUserInfo1: [AnyHashable: Any] = ["site": 9,
                                                              "offset": 1520590707.223]

            let invalidSilentUserInfo2: [AnyHashable: Any] = ["offset": 1520590707.223]

            context("default correct userInfo") {
                it("should create object") {
                    let request = NotificationUtils.notificationRequest(userInfo: userInfo, siteCode: 7)
                    expect(request).toNot(beNil())
                    expect(request?.content.title).to(equal("Reg: LD18 AAB - Paid"))
                    expect(request?.content.body).to(equal("Fixed penalty: ref001 (£250) has been paid"))
                    expect(request?.identifier).to(equal("TokenPaidNotification"))
                    expect(request?.trigger).to(beNil())
                }
            }

            context("default correct silentUserInfo") {
                it("should create object") {
                    let request = NotificationUtils.silentOffset(userInfo: silentUserInfo)
                    expect(request).to(equal(1520590707.223))
                }
            }

            context("invalid silentUserInfo") {

                it("should not create object") {
                    let request = NotificationUtils.silentOffset(userInfo: invalidSilentUserInfo1)
                    expect(request).to(beNil())
                }

                it("should not create object") {
                    let request = NotificationUtils.silentOffset(userInfo: invalidSilentUserInfo2)
                    expect(request).to(beNil())
                }
            }

            context("check invalid entries") {
                it("invalid site code") {
                    var userInfoSite = userInfo
                    expect(NotificationUtils.notificationRequest(userInfo: userInfoSite, siteCode: 7)).toNot(beNil())

                    expect(NotificationUtils.notificationRequest(userInfo: userInfoSite, siteCode: 8)).to(beNil())
                    userInfoSite["site"] = "wrongType"
                    expect(NotificationUtils.notificationRequest(userInfo: userInfoSite, siteCode: 7)).to(beNil())
                }
                it("invalid refNo") {
                    var userInfoRef = userInfo
                    userInfoRef["refNo"] = 123
                    expect(NotificationUtils.notificationRequest(userInfo: userInfoRef, siteCode: 7)).to(beNil())
                }
                it("invalid regNo") {
                    var userInfoReg = userInfo
                    userInfoReg["regNo"] = 123
                    expect(NotificationUtils.notificationRequest(userInfo: userInfoReg, siteCode: 7)).to(beNil())
                }
                it("other valid type") {
                    var userInfoType = userInfo
                    userInfoType["type"] = "CDN"
                    var request = NotificationUtils.notificationRequest(userInfo: userInfoType, siteCode: 7)
                    expect(request).toNot(beNil())
                    expect(request?.content.body).to(equal("Court deposit: ref001 (£250) has been paid"))

                    userInfoType["type"] = "IM"
                    request = NotificationUtils.notificationRequest(userInfo: userInfoType, siteCode: 7)
                    expect(request).toNot(beNil())
                    expect(request?.content.body).to(equal("Immobilisation: ref001 (£250) has been paid"))
                }
                it("invalid amount") {
                    var userInfoAmount = userInfo
                    userInfoAmount["amount"] = "wrongType"
                    expect(NotificationUtils.notificationRequest(userInfo: userInfoAmount, siteCode: 7)).to(beNil())
                }
                it("invalid status") {
                    var userInfoStatus = userInfo
                    userInfoStatus["status"] = 1
                    expect(NotificationUtils.notificationRequest(userInfo: userInfoStatus, siteCode: 7)).to(beNil())
                    userInfoStatus["status"] = "NOT PAID"
                    expect(NotificationUtils.notificationRequest(userInfo: userInfoStatus, siteCode: 7)).to(beNil())
                }
            }
        }
    }
}
