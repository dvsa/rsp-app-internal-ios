//
//  AWSDocumentModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import AWSCore

@objcMembers
public class AWSDocumentModel: AWSModel {

    var penaltyType: String?
    var paymentStatus: String?
    var paymentToken: String?
    var officerID: String?
    var siteCode: NSNumber?
    var formNo: String?
    var referenceNo: String?
    var driverDetails: AWSDriverDetailsModel?
    var vehicleDetails: AWSVehicleDetailsModel?
    var trailerDetails: AWSTrailerDetailsModel?
    var nonEndorsableOffence: [String]?
    var penaltyAmount: NSNumber?
    var paymentDueDate: Date?
    var officerName: String?
    var placeWhereIssued: String?
    var dateTime: Date?
    var paymentAuthCode: String?
    var paymentDate: Date?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]

        params["penaltyType"] = "penaltyType"
        params["paymentStatus"] = "paymentStatus"
        params["paymentToken"] = "paymentToken"
        params["officerID"] = "officerID"
        params["siteCode"] = "siteCode"
        params["formNo"] = "formNo"
        params["referenceNo"] = "referenceNo"
        params["driverDetails"] = "driverDetails"
        params["vehicleDetails"] = "vehicleDetails"
        params["trailerDetails"] = "trailerDetails"
        params["nonEndorsableOffence"] = "nonEndorsableOffence"
        params["penaltyAmount"] = "penaltyAmount"
        params["paymentDueDate"] = "paymentDueDate"
        params["officerName"] = "officerName"
        params["placeWhereIssued"] = "placeWhereIssued"
        params["dateTime"] = "dateTime"
        params["paymentAuthCode"] = "paymentAuthCode"
        params["paymentDate"] = "paymentDate"
        return params
    }

    public static func driverDetailsJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONDictionaryTransformer(withModelClass: AWSDriverDetailsModel.self)
    }

    public static func vehicleDetailsJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONDictionaryTransformer(withModelClass: AWSVehicleDetailsModel.self)
    }

    public static func trailerDetailsJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONDictionaryTransformer(withModelClass: AWSTrailerDetailsModel.self)
    }

    public static func dateTimeJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.timeIntervalSince1970JSONTransformer()
    }

    public static func paymentDueDateJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.timeIntervalSince1970JSONTransformer()
    }

    public static func paymentDateJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.timeIntervalSince1970JSONTransformer()
    }

}

extension String {

    static func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""

        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }

        return randomString
    }
}

extension AWSDocumentModel {

    class func generateRandomModel() -> AWSDocumentModel {

        let document = AWSDocumentModel()!

        document.formNo = "FPN 11/08"
        document.referenceNo = "\(arc4random_uniform(100000000))"

        let driverDetails = AWSDriverDetailsModel()!
        driverDetails.address = String.randomAlphaNumericString(length: 50)
        driverDetails.licenceNumber = String.randomAlphaNumericString(length: 12)
        driverDetails.name = "James Moriarty \(arc4random_uniform(100))"
        document.driverDetails = driverDetails

        let vehicleDetails = AWSVehicleDetailsModel()!
        vehicleDetails.make = "Rolls Royce"
        vehicleDetails.nationality = "XX"
        vehicleDetails.regNo = String.randomAlphaNumericString(length: 2) + "\(arc4random_uniform(100000))"
        document.vehicleDetails = vehicleDetails

        let trailerDetails = AWSTrailerDetailsModel()!
        trailerDetails.number1 = String.randomAlphaNumericString(length: 10)
        document.trailerDetails = trailerDetails

        document.nonEndorsableOffence = ["INCORRECT USE OF MODE SWITCH - ARTICLE 34(5) EU 165/2014, 27/10/2016"]
        document.penaltyAmount = NSNumber(value: UInt16(arc4random_uniform(9999)))

        document.dateTime = Date()
        document.paymentDueDate = Date(timeInterval: 3600*24*28, since: Date())
        document.officerName = "Officer \(arc4random_uniform(100))"
        document.placeWhereIssued = "BLACKWALL TUNNEL A, PAVILLION WAY, METROPOLITAN " + String.randomAlphaNumericString(length: 4)

        document.penaltyType = "FPN"
        document.paymentStatus = "UNPAID"
        document.officerID = "us-east-1:91d4966e-f803-4d83-8b76-13adc507728c"
        document.siteCode = 7

        let referenceNo = UInt64(document.referenceNo!) ?? 0
        let penaltyType = PenaltyType.fpn
        let penaltyAmount = document.penaltyAmount?.uint16Value

        let paymentToken = PaymentToken(referenceNo: referenceNo,
                                        penaltyType: penaltyType,
                                        penaltyAmount: penaltyAmount!)
        let key = Environment.tokenEncryptionKey
        document.paymentToken = paymentToken.encryptedToken(key: key)

        return document
    }

    func randomUpdate() {

        guard let referenceNo = self.referenceNo,
            let penaltyAmount = self.penaltyAmount else {
            return
        }

        self.driverDetails?.name = "James Moriarty \(arc4random_uniform(100))"
        self.penaltyAmount = NSNumber(value: UInt16(arc4random_uniform(9999)))
        self.penaltyType = "FPN"

        let referenceNoValue = UInt64(referenceNo) ?? 0
        let penaltyTypeValue = PenaltyType.fpn
        let penaltyAmountValue = UInt16(truncating: penaltyAmount)

        let paymentToken = PaymentToken(referenceNo: referenceNoValue,
                                        penaltyType: penaltyTypeValue,
                                        penaltyAmount: penaltyAmountValue)
        let key = Environment.tokenEncryptionKey
        self.paymentToken = paymentToken.encryptedToken(key: key)
    }
}
