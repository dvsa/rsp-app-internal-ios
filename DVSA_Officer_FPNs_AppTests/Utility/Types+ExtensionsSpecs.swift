//
//  Types+ExtensionsSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/01/2018.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class TypesExtensionsSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {

        describe("UInt8_Extensions") {
            context("toByteArray<T>") {
                it("should convert UInt16 to Little-Endian") {
                    let value = UInt16(1)
                    let output = toByteArray(value)
                    //[1,0]
                    expect(output.count).to(equal(2))
                    expect(output[0]).to(equal(1))
                    expect(output[1]).to(equal(0))

                    let value2 = UInt16(256)
                    let output2 = toByteArray(value2)
                    //[0,1]
                    expect(output2.count).to(equal(2))
                    expect(output2[0]).to(equal(0))
                    expect(output2[1]).to(equal(1))
                }

                it("should convert UInt32 to Little-Endian") {
                    let value = UInt32(1)
                    let output = toByteArray(value)
                    //[1, 0, 0, 0]
                    expect(output.count).to(equal(4))
                    expect(output[0]).to(equal(1))
                    expect(output[1]).to(equal(0))
                    expect(output[2]).to(equal(0))
                    expect(output[3]).to(equal(0))

                    let value2 = UInt32(256)
                    let output2 = toByteArray(value2)
                    //[0, 1, 0, 0]
                    expect(output2.count).to(equal(4))
                    expect(output2[0]).to(equal(0))
                    expect(output2[1]).to(equal(1))
                    expect(output[2]).to(equal(0))
                    expect(output[3]).to(equal(0))
                }

                it("should convert UInt64 to Little-Endian") {

                    let value2 = UInt64(4584397)
                    let output2 = toByteArray(value2)
                    //[205, 243, 69, 0, 0, 0, 0, 0]
                    expect(output2.count).to(equal(8))
                    expect(output2[0]).to(equal(205))
                    expect(output2[1]).to(equal(243))
                    expect(output2[2]).to(equal(69))
                    expect(output2[3]).to(equal(0))
                    expect(output2[4]).to(equal(0))
                    expect(output2[5]).to(equal(0))
                    expect(output2[6]).to(equal(0))
                    expect(output2[7]).to(equal(0))
                }
            }

            context("fromByteArray") {

                it("should revert UInt16 from Little-Endian") {
                    let value: [UInt8] = [1, 0]
                    let output = fromByteArray(value, UInt16.self)
                    //1
                    expect(output).to(equal(1))
                    let value2: [UInt8] = [0, 1]
                    let output2 =  fromByteArray(value2, UInt16.self)
                    //256
                    expect(output2).to(equal(256))
                }

                it("should revert UInt32 from Little-Endian") {
                    let value: [UInt8] = [1, 0, 0, 0]
                    let output = fromByteArray(value, UInt32.self)
                    //1
                    expect(output).to(equal(1))
                    let value2: [UInt8] = [0, 1, 0, 0]
                    let output2 =  fromByteArray(value2, UInt32.self)
                    //256
                    expect(output2).to(equal(256))
                }

                it("should revert UInt64 from Little-Endian") {
                    let value: [UInt8] = [205, 243, 69, 0, 0, 0, 0, 0]
                    let output = fromByteArray(value, UInt64.self)
                    //4584397
                    expect(output).to(equal(4584397))
                }
            }
        }

        describe("Array") {
            context("splitBy") {
                it("should create an Array of Array") {
                    let array = [12, 13, 24, 25, 15]
                    let result = array.splitBy(subSize: 2)
                    expect(result).toNot(beNil())
                    expect(result.count).to(equal(3))
                    expect(result[0].count).to(equal(2))
                    expect(result[1].count).to(equal(2))
                    expect(result[2].count).to(equal(1))
                    expect(result[0][0]).to(equal(12))
                    expect(result[0][1]).to(equal(13))
                    expect(result[1][0]).to(equal(24))
                    expect(result[1][1]).to(equal(25))
                    expect(result[2][0]).to(equal(15))
                }
            }
        }

        describe("Data") {
            context("hexEncodedString") {
                it("should encode to hexString") {

                    let data = Data([UInt8(0), UInt8(255)])
                    let hexString = data.hexEncodedString()
                    expect(hexString).to(equal("00ff"))

                    let hexStringUppercase = data.hexEncodedString(options: [.upperCase])
                    expect(hexStringUppercase).to(equal("00FF"))
                }
            }

            context("hexEncodedString") {
                it("init fromHexEncodedString") {
                    let data = Data(fromHexEncodedString: "00ff")
                    expect(data).toNot(beNil())
                    expect(data?[0]).to(equal(0))
                    expect(data?[1]).to(equal(255))

                    let data2 = Data(fromHexEncodedString: "00FF")
                    expect(data2).toNot(beNil())
                    expect(data2?[0]).to(equal(0))
                    expect(data2?[1]).to(equal(255))

                    let data3 = Data(fromHexEncodedString: "00F")
                    expect(data3).to(beNil())

                    let data4 = Data(fromHexEncodedString: "00KK")
                    expect(data4).to(beNil())
                }
            }
        }
    }
}
