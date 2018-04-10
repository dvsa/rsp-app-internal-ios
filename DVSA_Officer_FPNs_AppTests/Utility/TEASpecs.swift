//
//  TEASpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 22/01/2018.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class TEASpecs: QuickSpec {

    override func spec() {

        describe("TEA") {

            let testDecryptKey: [UInt32] = [0x78, 0x90, 0x89, 0x78]

            context("wordArray") {
                it("should convert") {
                    let wordArray1 = wordArray(from: [1, 1, 1, 1])
                    expect(wordArray1.count).to(equal(1))
                    expect(wordArray1[0]).to(equal(16843009))
                    //[16843009]
                    let wordArray2 = wordArray(from: [1, 1])
                    expect(wordArray2.count).to(equal(1))
                    expect(wordArray2[0]).to(equal(257))

                    let wordArray3 = wordArray(from: [1, 1, 1, 1, 1])
                    expect(wordArray3.count).to(equal(2))
                    expect(wordArray3[0]).to(equal(16843009))
                    expect(wordArray3[1]).to(equal(1))
                }
            }
            context("byteArray") {
                it("should convert") {
                    let byteArray1 = byteArray(from: [16843009])
                    expect(byteArray1.count).to(equal(4))
                    expect(byteArray1[0]).to(equal(1))
                    expect(byteArray1[1]).to(equal(1))
                    expect(byteArray1[2]).to(equal(1))
                    expect(byteArray1[3]).to(equal(1))

                    let byteArray2 = byteArray(from: [257])
                    expect(byteArray2.count).to(equal(4))
                    expect(byteArray2[0]).to(equal(1))
                    expect(byteArray2[1]).to(equal(1))
                    expect(byteArray2[2]).to(equal(0))
                    expect(byteArray2[3]).to(equal(0))

                    let byteArray3 = byteArray(from: [16843009, 1])
                    expect(byteArray3.count).to(equal(8))
                    expect(byteArray3[0]).to(equal(1))
                    expect(byteArray3[1]).to(equal(1))
                    expect(byteArray3[2]).to(equal(1))
                    expect(byteArray3[3]).to(equal(1))
                    expect(byteArray3[4]).to(equal(1))
                    expect(byteArray3[5]).to(equal(0))
                    expect(byteArray3[6]).to(equal(0))
                    expect(byteArray3[7]).to(equal(0))
                }
            }
            context("encryptTEA") {
                it("should encrypt") {
                    let testValue: [UInt32] = [0xAA, 0xFF]
                    let testEncryptTEA = encryptTEA(value: testValue, key: testDecryptKey)
                    expect(testEncryptTEA?.count).to(equal(2))
                    expect(testEncryptTEA?[0]).to(equal(272392185))
                    expect(testEncryptTEA?[1]).to(equal(2676738055))
                }
            }
            context("decryptTEA") {
                it("should decrypt") {
                    let testEncryptedValue: [UInt32] = [272392185, 2676738055] //2 Word
                    let testEncryptTEA1 = decryptTEA(value: testEncryptedValue, key: testDecryptKey)
                    expect(testEncryptTEA1?.count).to(equal(2))
                    expect(testEncryptTEA1?[0]).to(equal(170))
                    expect(testEncryptTEA1?[1]).to(equal(255))
                }
            }

            context("keyTEA") {

                it ("should decode comma separated hex") {
                    let code = "78,90,89,78"
                    let key = keyTEA(from: code)
                    expect(key.count).to(equal(4))
                    expect(key[0]).to(equal(testDecryptKey[0]))
                    expect(key[1]).to(equal(testDecryptKey[1]))
                    expect(key[2]).to(equal(testDecryptKey[2]))
                    expect(key[3]).to(equal(testDecryptKey[3]))
                }

                it ("should decode comma separated hex") {
                    let testDecryptKey: [UInt32] = [0x89000078, 0x10000090, 0x00000089, 0x78]
                    let code = "89000078,10000090,89,78"
                    let key = keyTEA(from: code)
                    expect(key.count).to(equal(4))
                    expect(key[0]).to(equal(testDecryptKey[0]))
                    expect(key[1]).to(equal(testDecryptKey[1]))
                    expect(key[2]).to(equal(testDecryptKey[2]))
                    expect(key[3]).to(equal(testDecryptKey[3]))
                }
            }
        }
    }
}
