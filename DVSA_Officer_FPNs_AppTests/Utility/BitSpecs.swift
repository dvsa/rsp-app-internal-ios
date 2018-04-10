//
//  BitSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 19/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class BitSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {

        describe("Bit") {
            context("bitArray(from: String)") {
                it("should return [Bit]") {
                    let value = Bit.bitArray(from: "010")
                    expect(value[0]).to(equal(Bit.zero))
                    expect(value[1]).to(equal(Bit.one))
                    expect(value[2]).to(equal(Bit.zero))
                }
            }
            context("toString(from: [Bit])") {
                it("should return String") {
                    let value = Bit.toString(from: [.one, .zero, .one, .zero])
                    expect(value).to(equal("1010"))
                }
            }

            context("bitArray(from byte: UInt8)") {
                it("should return [Bit] with Less significant digit first") {

                    let bitTest1 = Bit.bitArray(from: UInt8(1))
                    let result1 = Bit.toString(from: bitTest1)
                    expect(result1).to(equal("10000000"))

                    let bitTest254 = Bit.bitArray(from: UInt8(254))
                    let result254 = Bit.toString(from: bitTest254)
                    expect(result254).to(equal("01111111"))

                    let bitTest255 = Bit.bitArray(from: UInt8(255))
                    let result255 = Bit.toString(from: bitTest255)
                    expect(result255).to(equal("11111111"))
                }
            }

            context("toByte(from bits: [Bit])") {
                it("should return UInt8 from a [Bit] Less significant digit first") {

                    let byteTest1 = Bit.bitArray(from: "10000000")
                    let result1 = Bit.toByte(from: byteTest1)
                    expect(result1).to(equal(UInt8(1)))

                    let byteTest1M = Bit.bitArray(from: "10000")
                    let result1M = Bit.toByte(from: byteTest1M)
                    expect(result1M).to(equal(UInt8(1)))

                    let byteTest1M2 = Bit.bitArray(from: "100000001")
                    let result1M2 = Bit.toByte(from: byteTest1M2)
                    expect(result1M2).to(equal(UInt8(1)))

                    let byteTest254 = Bit.bitArray(from: "01111111")
                    let result254 = Bit.toByte(from: byteTest254)
                    expect(result254).to(equal(UInt8(254)))

                }
            }

            context("bits(from: T, size: Int") {
                it("should convert from UInt8") {
                    let bits1 = Bit.bits(from: UInt8(1), size: 8)
                    let testBit1 = "10000000"
                    let result1 = Bit.toString(from: bits1)
                    expect(result1).to(equal(testBit1))

                    let bits255 = Bit.bits(from: UInt8(255), size: 7)
                    let testBit255 = "1111111"
                    expect(Bit.toString(from: bits255)).to(equal(testBit255))
                }

                it("should convert from UInt16") {
                    let bits1 = Bit.bits(from: UInt16(1), size: 16)
                    let testBit1 = "1000000000000000"
                    expect(Bit.toString(from: bits1)).to(equal(testBit1))

                    let bits255 = Bit.bits(from: UInt16(255), size: 7)
                    let testBit255 = "1111111"
                    expect(Bit.toString(from: bits255)).to(equal(testBit255))
                }

                it("should convert from UInt32") {
                    let bits1 = Bit.bits(from: UInt64(1), size: 64)
                    let testBit1 = "1000000000000000000000000000000000000000000000000000000000000000"
                    expect(Bit.toString(from: bits1)).to(equal(testBit1))
                    let bits255 = Bit.bits(from: UInt64(255), size: 7)
                    let testBit255 = "1111111"
                    expect(Bit.toString(from: bits255)).to(equal(testBit255))

                }
            }

            context("bytes(from: [Bit]") {
                it("should convert to UInt8 Array") {
                    let bytes1 = Bit.bytes(from: [.one, .zero, .zero, .zero])
                    expect(bytes1.count).to(equal(1))
                    expect(bytes1[0]).to(equal(1))

                    let bytes2 = Bit.bytes(from: [.one, .zero, .zero, .zero,
                                                  .zero, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .zero, .zero, .zero])
                    expect(bytes2.count).to(equal(2))
                    expect(bytes2[0]).to(equal(1))
                    expect(bytes2[1]).to(equal(1))

                    let bytes3 = Bit.bytes(from: [.one, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .zero])
                    expect(bytes3.count).to(equal(2))
                    expect(bytes3[0]).to(equal(1))
                    expect(bytes3[1]).to(equal(1))
                }
            }

            context("resize") {
                it("should resize to requested size") {
                    let resize1 = Bit.resize(bits: [.one, .zero, .zero, .zero], size: 2)
                    let result1 = Bit.toString(from: resize1)
                    expect(result1).to(equal("10"))

                    let resize2 = Bit.resize(bits: [.one, .zero, .zero, .zero], size: 8)
                    let result2 = Bit.toString(from: resize2)
                    expect(result2).to(equal("10000000"))
                }
            }

        }
    }
}
