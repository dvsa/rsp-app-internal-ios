//
//  PaymentTokenSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 22/01/2018.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class PaymentTokenSpecs: QuickSpec {
    override func spec() {
        describe("PaymentToken") {

            let bitTokenString = "1001001100100000110111111000111011111000100001000101111100000000"
            let bitToken = Bit.bitArray(from: bitTokenString)
            let key: [UInt32] = [0x78, 0x90, 0x89, 0x78]

            context("init") {
                it("should init from Bit Array") {
                    let paymentToken = PaymentToken(token: bitToken)
                    expect(paymentToken).toNot(beNil())
                }
            }

            context("properties") {
                let paymentToken = PaymentToken(token: bitToken)
                context("referenceNo") {
                    it("should decode the bit token") {
                        expect(paymentToken?.referenceNo).to(equal(1234567890121))
                    }
                }
                context("documentType") {
                    it("should decode the bit token") {
                        expect(paymentToken?.penaltyType?.rawValue).to(equal(PenaltyType.deposit.rawValue))
                    }
                }
                context("penaltyAmount") {
                    it("should decode the bit token") {
                        expect(paymentToken?.penaltyAmount).to(equal(1000))
                    }
                }

                context("encryptedToken") {
                    it("should return encrypted token") {
                        let encryptedToken = paymentToken?.encryptedToken(key: key)
                        expect(encryptedToken).to(equal("0e5b518dda12f4d3"))
                    }
                }
            }

            context("decryptToken") {
                it("should decrypt the token") {
                    let decryptedTokenBit = PaymentToken.decryptToken(token: "0e5b518dda12f4d3", key: key)!
                    let decryptedTokenString = Bit.toString(from: decryptedTokenBit)
                    expect(decryptedTokenString).to(equal(bitTokenString))
                }

                it("should init from decrypted token") {

                    let pt = PaymentToken(token: "0e5b518dda12f4d3", key: key)
                    expect(pt).toNot(beNil())
                    expect(pt?.referenceNo).to(equal(1234567890121))
                    expect(pt?.penaltyType?.rawValue).to(equal(PenaltyType.deposit.rawValue))
                    expect(pt?.penaltyAmount).to(equal(1000))
                }
            }
        }
    }
}
