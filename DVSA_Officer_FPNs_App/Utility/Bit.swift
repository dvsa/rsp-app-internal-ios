//
//  Bit.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

// MARK: Bit utils

enum Bit: UInt8, CustomStringConvertible {
    case zero, one
    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }

    /**

     Convert a string containg [0..1] to a Bit array
     ```
     let bitTest1 = bitArray(from: "10000000")
     // [1, 0, 0, 0, 0, 0, 0, 0]
     let bitTest254 = bitArray(from: "01111111")
     // [0, 1, 1, 1, 1, 1, 1, 1]
     let bitTest255 = bitArray(from: "11111111")
     // [1, 1, 1, 1, 1, 1, 1, 1]
     ```
     */
    static func bitArray(from bitString: String) -> [Bit] {
        var bits = [Bit]()
        for char in bitString {
            if char == "0" {
                bits.append(.zero)
            } else if char == "1" {
                bits.append(.one)
            }
        }
        return bits
    }

    /**

     Convert a Bit array to a string containg [0..1]
     ```
     let stringTest1 = toString(from: [.one, .zero, .one])
     // "101"
     ```
     */
    static func toString(from bits: [Bit]) -> String {
        var string = ""
        for bit in bits {
            switch bit {
            case .one:
                string.append("1")
            case .zero:
                string.append("0")
            }
        }
        return string
    }

    /**

     Convert UInt8 to a Bit array with the Less significant digit first
     ```
     let bitTest1 = bitArray(from: UInt8(1))
     // [1, 0, 0, 0, 0, 0, 0, 0]
     let bitTest254 = bitArray(from: UInt8(254))
     // [0, 1, 1, 1, 1, 1, 1, 1]
     let bitTest255 = bitArray(from: UInt8(255))
     // [1, 1, 1, 1, 1, 1, 1, 1]
     ```
     */
    static func bitArray(from byte: UInt8) -> [Bit] {
        var byte = byte
        var bits = [Bit](repeating: .zero, count: 8)
        for value in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[value] = .one
            }
            byte >>= 1
        }
        return bits
    }

    /**

     Revert to UInt8 truncated from a Bit array with size 8 with Less significant digit first
     ```
     let byteTest1 = toByte(from: [1, 0, 0, 0, 0, 0, 0, 0])
     // 1
     let byteTest1 = toByte(from: [1, 0, 0, 0, 0, 0, 0, 0, 1])
     // 1
     let byteTest254 = toByte(from: [0, 1, 1, 1, 1, 1, 1, 1])
     // 254
     let byteTest255 = toByte(from: [1, 1, 1, 1, 1, 1, 1, 1])
     // 255
     ```
     */
    static func toByte(from bits: [Bit]) -> UInt8 {

        var byte: UInt8 = 0
        var bits = bits

        let padding = 8 - bits.count % 8
        if padding != 8 {
            let paddingBit = [Bit](repeating: .zero, count: padding)
            bits.append(contentsOf: paddingBit)
        }

        for value in 0...7 {
            var bit = bits[value].rawValue
            bit <<= value
            byte = byte | bit
        }
        return byte
    }

    static internal func getBits<T>(from: T, size: Int) -> [Bit] {
        let byteArray = toByteArray(from)
        var bitList = [Bit]()
        for byte in byteArray {
            let bits = Bit.bitArray(from: byte)
            bitList.append(contentsOf: bits)
        }
        if bitList.count < size {
            let padding = size - bitList.count
            let paddingBit = [Bit](repeating: .zero, count: padding)
            bitList.append(contentsOf: paddingBit)
        } else if bitList.count > size {
            let num = bitList.count - size
            bitList.removeLast(num)
        }
        return bitList
    }

    static func bits(from: UInt8, size: Int) -> [Bit] {
        return getBits(from: from, size: size)
    }

    static func bits(from: UInt16, size: Int) -> [Bit] {
        return getBits(from: from, size: size)
    }

    static func bits(from: UInt64, size: Int) -> [Bit] {
        return getBits(from: from, size: size)
    }

    static func bits(from byte: [UInt8]) -> [Bit] {
        var bitList = [Bit]()
        for byte in byte {
            let bits = Bit.bitArray(from: byte)
            bitList.append(contentsOf: bits)
        }
        return bitList
    }

    static func bytes(from: [Bit]) -> [UInt8] {

        var from = from
        let paddingSize = 8 - from.count % 8
        if paddingSize != 8 {
            let bitsPadding = bits(from: UInt8(0), size: paddingSize)
            from.append(contentsOf: bitsPadding)
        }
        let vBits = from.splitBy(subSize: 8)
        var value = [UInt8]()
        for vBit in vBits {
            let fBit = toByte(from: vBit)
            value.append(fBit)
        }
        return value
    }

    static func resize(bits: [Bit], size: Int) -> [Bit] {
        var bitList = bits

        if bitList.count < size {
            let padding = size - bitList.count
            for _ in 0..<padding {
                bitList.append(Bit.zero)
            }
        } else if bitList.count > size {
            let num = bitList.count - size
            bitList.removeLast(num)
        }
        return bitList
    }
}
