//
//  DateUtilitySpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Yue Chen on 25/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Nimble
import Quick

@testable import DVSA_Officer_FPNs_App

class DateUtilitySpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        let date = Date()
        describe("Date utility") {
            context("trucate") {
                it("remove seconds") {
                    let dateNoSeconds = date.zeroSeconds
                    let calender = Calendar.current
                    let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateNoSeconds)
                    expect(dateComponents.year).toNot(beNil())
                    expect(dateComponents.month).toNot(beNil())
                    expect(dateComponents.day).toNot(beNil())
                    expect(dateComponents.hour).toNot(beNil())
                    expect(dateComponents.minute).toNot(beNil())
                    expect(dateComponents.second).to(equal(0))
                }
                it("remove time") {
                    let dateNoSeconds = date.dateOnly
                    let calender = Calendar.current
                    let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateNoSeconds)
                    expect(dateComponents.year).toNot(beNil())
                    expect(dateComponents.month).toNot(beNil())
                    expect(dateComponents.day).toNot(beNil())
                    expect(dateComponents.hour).to(equal(0))
                    expect(dateComponents.minute).to(equal(0))
                    expect(dateComponents.second).to(equal(0))
                }
            }

            context("today") {
                it("should convert date to the midnight") {
                    let date = Date.todayUTC
                    let now = Date()
                    let calender = Calendar.utc
                    let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    let nowComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
                    expect(dateComponents.year).to(equal(nowComponents.year))
                    expect(dateComponents.month).to(equal(nowComponents.month))
                    expect(dateComponents.day).to(equal(nowComponents.day))
                    expect(dateComponents.hour).to(equal(0))
                    expect(dateComponents.minute).to(equal(0))
                    expect(dateComponents.second).to(equal(0))
                }
            }

            context("String utility") {
                let dateForString = Date(timeIntervalSince1970: 1516898361)
                let dateString = "27/10/2017"
                it("DVSA string format") {
                    expect(dateForString.dvsaDateString).to(equal("25/01/2018"))
                }
                it("Date from DVSA string") {
                    let dateFromDVSA = Date.dateFromDvsaString(string: dateString) ?? Date()
                    let calender = Calendar.current
                    let dateComponents = calender.dateComponents([.year, .month, .day], from: dateFromDVSA)
                    expect(dateComponents.year).to(equal(2017))
                    expect(dateComponents.month).to(equal(10))
                    expect(dateComponents.day).to(equal(27))
                }

                it("dvsaLastSyncDateTimeString") {
                    let date = Date()
                    let dateYesterday = date.addingTimeInterval(-60*60*24)
                    let twoDaysAgo = date.addingTimeInterval(-60*60*24*2)
                    expect(date.dvsaLastSyncDateTimeString).to(beginWith("Today at "))
                    expect(dateYesterday.dvsaLastSyncDateTimeString).to(beginWith("Yesterday at "))
                    expect(twoDaysAgo.dvsaLastSyncDateTimeString).toNot(beginWith("Today at "))
                    expect(twoDaysAgo.dvsaLastSyncDateTimeString).toNot(beginWith("Yesterday at "))
                }
            }
            context("date difference") {
                let date1 = Date(timeIntervalSince1970: 1516898361) //25 January 2018 16:39:21
                let date2 = Date(timeIntervalSince1970: 1516905104) //25 January 2018 18:31:44
                let date3 = Date(timeIntervalSince1970: 1516905704) //25 January 2018 18:41:44
                let date4 = Date(timeIntervalSince1970: 1517323247) //30 January 2018 14:40:47
                expect(date2.hours(from: date1)).to(equal(1))
                expect(date3.hours(from: date1)).to(equal(2))
                expect(date4.hours(from: date1) > 24).to(beTrue())
            }
        }
    }
}
