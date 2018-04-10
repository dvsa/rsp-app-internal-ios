//
//  PaymentToken.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 17/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

let maxPaymentTokenReferenceNo = UInt64(pow(2.0, 44.0))
let maxPaymentTokenAmount = UInt16(pow(2.0, 14.0))

struct PaymentToken {

    private var bitsToken: [Bit]

    var referenceNo: UInt64 {
        let sliceBitsReferenceNo = [Bit](bitsToken[0...43])
        let bitsRefrenceNo2 = Bit.resize(bits: sliceBitsReferenceNo, size: 64)
        let bytesReferenceNo2 = Bit.bytes(from: bitsRefrenceNo2)
        return fromByteArray(bytesReferenceNo2, UInt64.self)
    }

    var penaltyType: PenaltyType? {
        let sliceBitsPenaltyType = [Bit](bitsToken[44...45])
        let bitsPenaltyType2 = Bit.resize(bits: sliceBitsPenaltyType, size: 8)
        let bytesPenaltyType2 = Bit.bytes(from: bitsPenaltyType2)
        let decryptedPenaltyType2 = fromByteArray(bytesPenaltyType2, UInt8.self)
        return PenaltyType(rawValue: decryptedPenaltyType2)
    }

    var penaltyAmount: UInt16 {
        let sliceAmount = [Bit](bitsToken[46...59])
        let bitsAmount2 = Bit.resize(bits: sliceAmount, size: 16)
        let bytesAmount2 = Bit.bytes(from: bitsAmount2)
        return fromByteArray(bytesAmount2, UInt16.self)

    }

    init?(document: DocumentObject) {

        if let penaltyType = document.getPenaltyType(),
            let referenceNoString = document.referenceNo.immobTokenRef(type: penaltyType),
            let referenceNo = UInt64(referenceNoString),
            let amount = UInt16(document.penaltyAmount),
            referenceNo < maxPaymentTokenReferenceNo,
            amount < maxPaymentTokenAmount {
            self.init(referenceNo: referenceNo, penaltyType: penaltyType, penaltyAmount: amount)
        } else {
            return nil
        }
    }

    init(referenceNo: UInt64, penaltyType: PenaltyType, penaltyAmount: UInt16) {

        let bitsRefrenceNo = Bit.bits(from: referenceNo, size: 44)
        let bitsPenaltyType = Bit.bits(from: penaltyType.rawValue, size: 2)
        let bitsAmount = Bit.bits(from: penaltyAmount, size: 14)
        let bitsPadding = Bit.bits(from: UInt8(0), size: 4)

        bitsToken = [Bit]()
        bitsToken.append(contentsOf: bitsRefrenceNo)
        bitsToken.append(contentsOf: bitsPenaltyType)
        bitsToken.append(contentsOf: bitsAmount)
        bitsToken.append(contentsOf: bitsPadding)
    }

    init?(token: [Bit]) {
        guard token.count == 64 else {
            return nil
        }
        self.bitsToken = token
    }

    init?(token: String, key: [UInt32]) {

        guard let bitsToken = PaymentToken.decryptToken(token: token, key: key) else {
            return nil
        }
        self.bitsToken = bitsToken
    }

    func encryptedToken(key: [UInt32]) -> String? {
        guard key.count == 4 else {
            return nil
        }
        let tokenBytesArray = Bit.bytes(from: self.bitsToken)
        let tokenWordArray = wordArray(from: tokenBytesArray)
        guard let encryptedWordArray = encryptTEA(value: tokenWordArray, key: key) else {
            return nil
        }
        let encryptedTokenByteArray = byteArray(from: encryptedWordArray)
        let hex = Data(encryptedTokenByteArray).hexEncodedString()
        return hex
    }

    static func decryptToken(token: String, key: [UInt32]) -> [Bit]? {

        guard key.count == 4,
            let encryptedTokenData = Data(fromHexEncodedString: token) else {
            return nil
        }
        let encryptedTokenByteArray2 = [UInt8](encryptedTokenData)
        let tokenWordArray2 = wordArray(from: encryptedTokenByteArray2)
        guard let decryptedToken = decryptTEA(value: tokenWordArray2, key: key) else {
            return nil
        }
        let decryptedTokenByteArray = byteArray(from: decryptedToken)
        let decryptedBits = Bit.bits(from: decryptedTokenByteArray)
        return decryptedBits
    }
}
