//
//  PaymentStatusSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 02/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class PaymentStatusSpecs: QuickSpec {

    override func spec() {

        describe("PaymentStatus") {
            context("type") {
                it("should code the rawValue") {
                    expect(PaymentStatus.unpaid.rawValue).to(equal(0))
                    expect(PaymentStatus.paid.rawValue).to(equal(1))
                    expect(PaymentStatus(rawValue: 2)).to(beNil())
                }
            }

            context("value") {
                it("should return a valid PaymentStatus") {
                    expect(PaymentStatus.value(from: "UNPAID")?.rawValue).to(equal(0))
                    expect(PaymentStatus.value(from: "PAID")?.rawValue).to(equal(1))
                    expect(PaymentStatus.value(from: "paid")).to(beNil())
                    expect(PaymentStatus.value(from: "unpaid")).to(beNil())
                }
            }

            context("toString") {
                it("should return a valid PaymentStatus") {
                    expect(PaymentStatus.unpaid.toString()).to(equal("UNPAID"))
                    expect(PaymentStatus.paid.toString()).to(equal("PAID"))
                }
            }
        }

        describe("DocumentObject extension") {
            context("getPaymentStatus") {
                it("should return a valid PaymentStatus") {
                    let document = DocumentObject()
                    let defaultValue = document.getPaymentStatus()?.rawValue
                    expect(PaymentStatus.unpaid.rawValue).to(equal(defaultValue))

                    document.paymentStatus = 1
                    let paid = document.getPaymentStatus()?.rawValue
                    expect(PaymentStatus.paid.rawValue).to(equal(paid))

                    document.paymentStatus = -1
                    let invalid = document.getPaymentStatus()?.rawValue
                    expect(invalid).to(beNil())

                    document.paymentStatus = 2
                    let invalid2 = document.getPaymentStatus()?.rawValue
                    expect(invalid2).to(beNil())
                }
            }

            context("setPaymentStatus") {
                it("should set a valid PaymentStatus") {

                    let document = DocumentObject()

                    document.setPaymentStatus(paymentStatus: PaymentStatus.unpaid)
                    expect(PaymentStatus.unpaid.rawValue).to(equal(UInt8(document.paymentStatus)))

                    document.setPaymentStatus(paymentStatus: PaymentStatus.paid)
                    expect(PaymentStatus.paid.rawValue).to(equal(UInt8(document.paymentStatus)))

                }
            }

        }
    }
}
