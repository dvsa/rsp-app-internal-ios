//
//  TEA.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

func wordArray(from: [UInt8]) -> [UInt32] {
    var from = from
    let padding = 4 - from.count % 4
    if padding != 4 {
        let bitsPadding = [UInt8](repeating: UInt8(0), count: padding)
        from.append(contentsOf: bitsPadding)
    }
    let vBits = from.splitBy(subSize: 4)
    var value = [UInt32]()
    for val in vBits {
        let fval = fromByteArray(val, UInt32.self)
        value.append(fval)
    }
    return value
}

func byteArray(from: [UInt32]) -> [UInt8] {

    var value = [UInt8]()
    for word in from {
        let array = toByteArray(word)
        value.append(contentsOf: array)
    }
    return value
}

func encryptTEA (value: [UInt32], key: [UInt32]) -> [UInt32]? {

    guard value.count == 2 && key.count == 4 else {
        return nil
    }

    var val0: UInt32 = value[0]
    var val1: UInt32 = value[1]

    var sum: UInt32 = 0
    /* set up */
    let delta: UInt32 = 0x9e3779b9/* a key schedule constant */

    for _ in 0...31 {/* basic cycle start */

        sum = sum &+ delta

        val0 = val0 &+ (((val1<<4) &+ key[0]) ^ (val1 &+ sum) ^ ((val1>>5) &+ key[1]))

        val1 = val1 &+ (((val0<<4) &+ key[2]) ^ (val0 &+ sum) ^ ((val0>>5) &+ key[3]))

    }
    var output: [UInt32] = [0x00, 0x00]
    output[0] = val0
    output[1] = val1
    return output
}

func decryptTEA (value: [UInt32], key: [UInt32]) -> [UInt32]? {

    guard value.count == 2 && key.count == 4 else {
        return nil
    }

    var val0: UInt32 = value[0]
    var val1: UInt32 = value[1]
    var sum: UInt32 = 0xC6EF3720  /* set up */
    let delta: UInt32 = 0x9e3779b9                     /* a key schedule constant */

    for _ in 0...31 {/* basic cycle start */

        val1 = val1 &- (((val0<<4) &+ key[2]) ^ (val0 &+ sum) ^ ((val0>>5) &+ key[3]))
        val0 = val0 &- (((val1<<4) &+ key[0]) ^ (val1 &+ sum) ^ ((val1>>5) &+ key[1]))
        sum = sum &- delta

    }

    var output: [UInt32] = [0x00, 0x00]
    output[0] = val0
    output[1] = val1
    return output
}

func keyTEA(from code: String) -> [UInt32] {
    let values = code.split(separator: ",")

    let decodeKey = values.map { (value) -> UInt32 in
        return UInt32(String(value), radix: 16) ?? 0
    }
    return decodeKey
}
