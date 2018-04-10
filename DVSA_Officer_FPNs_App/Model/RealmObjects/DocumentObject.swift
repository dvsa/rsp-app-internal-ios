//
//  DocumentObject.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

class DocumentObject: Object, Model {

    //WARNING: Due to Realm limits, please use configure to set these values
    //Use set(penaltyType: PenaltyType, referenceNo: String)
    @objc dynamic var key: String = ""
    @objc dynamic var penaltyType: Int8 = Int8(PenaltyType.fpn.rawValue)
    @objc dynamic var referenceNo: String = ""

    @objc dynamic var paymentStatus: Int8 = Int8(PaymentStatus.unpaid.rawValue)
    @objc dynamic var overridden: Bool = false
    @objc dynamic var paymentToken: String?
    @objc dynamic var officerID: String = ""
    @objc dynamic var siteCode: Int = 0
    @objc dynamic var formNo: String?
    @objc dynamic var driverDetails: DriverDetailsObject?
    @objc dynamic var vehicleDetails: VehicleDetailsObject?
    @objc dynamic var trailerDetails: TrailerDetailsObject?
    @objc dynamic var penaltyAmount: String = ""
    @objc dynamic var paymentDueDate: Date?
    @objc dynamic var officerName: String = ""
    @objc dynamic var placeWhereIssued: String?
    @objc dynamic var dateTime: Date?
    @objc dynamic var paymentAuthCode: String?
    @objc dynamic var paymentDate: Date?

    var nonEndorsableOffence = List<String>()

    override public class func primaryKey() -> String? {
        return "key"
    }

    func setKey(referenceNo: String, penaltyType: PenaltyType) {
        self.penaltyType = Int8(penaltyType.rawValue)
        self.referenceNo = referenceNo
        let penaltyTypeToString = penaltyType.toString()
        self.referenceNo = referenceNo
        let referenceNoForKey = referenceNo.immobTokenRef(type: penaltyType) ?? ""
        self.key = "\(referenceNoForKey)_\(penaltyTypeToString)"
    }

    convenience init?(model: AWSDocumentModel) {
        guard let penaltyTypeString = model.penaltyType,
            let penaltyType = PenaltyType.value(from: penaltyTypeString),
            let paymentStatusString = model.paymentStatus,
            let paymentStatus = PaymentStatus.value(from: paymentStatusString),
            let paymentToken = model.paymentToken,
            let officerID = model.officerID,
            let siteCode = model.siteCode,
            let referenceNo = model.referenceNo,
            let penaltyAmount = model.penaltyAmount,
            let dateTime = model.dateTime,
            let officerName = model.officerName else {
                return nil
        }
        self.init()
        self.setKey(referenceNo: referenceNo, penaltyType: penaltyType)
        self.setPaymentStatus(paymentStatus: paymentStatus)
        self.paymentToken = paymentToken
        self.officerID = officerID
        self.siteCode = siteCode.intValue
        self.formNo = model.formNo
        if let modelDiriverDetails = model.driverDetails {
            self.driverDetails = DriverDetailsObject(model: modelDiriverDetails)
        }
        if let modelVehicleDetails = model.vehicleDetails {
            self.vehicleDetails = VehicleDetailsObject(model: modelVehicleDetails)
        }
        if let modelTrailerDetails = model.trailerDetails {
            self.trailerDetails = TrailerDetailsObject(model: modelTrailerDetails)
        }
        if let modelNonEndorsableOffence = model.nonEndorsableOffence {
            for item in modelNonEndorsableOffence {
                self.nonEndorsableOffence.append(item)
            }
        }
        self.penaltyAmount = penaltyAmount.stringValue
        self.paymentDueDate = model.paymentDueDate
        self.officerName = officerName
        self.placeWhereIssued = model.placeWhereIssued
        self.dateTime = dateTime
        self.paymentAuthCode = model.paymentAuthCode
        self.paymentDate = model.paymentDate
    }

    func awsModel() -> AWSDocumentModel? {
        return AWSDocumentModel(object: self)
    }

    func isEqualToModel(model: AWSDocumentModel) -> Bool {

        var isEqualDriverDetails = true
        if let driverDetails = self.driverDetails {
            if let modelDriverDetails = model.driverDetails {
                isEqualDriverDetails = driverDetails.isEqualToModel(model: modelDriverDetails)
            } else {
                isEqualDriverDetails = false
            }
        }

        var isEqualTrailerDetails = true
        if let trailerDetails = self.trailerDetails {
            if let modelTrailerDetails = model.trailerDetails {
                isEqualTrailerDetails = trailerDetails.isEqualToModel(model: modelTrailerDetails)
            } else {
                isEqualTrailerDetails = false
            }
        }

        var isEqualVehicleDetails = true
        if let vehicleDetails = self.vehicleDetails {
            if let modelVehicleDetails = model.vehicleDetails {
                isEqualVehicleDetails = vehicleDetails.isEqualToModel(model: modelVehicleDetails)
            } else {
                isEqualVehicleDetails = false
            }
        }

        var isEqualNonEndorsableOffence = true

        for value in 0..<self.nonEndorsableOffence.count {
            isEqualNonEndorsableOffence = isEqualNonEndorsableOffence && self.nonEndorsableOffence[value] == model.nonEndorsableOffence?[value]
        }

        let isEqualValue = self.formNo == model.formNo &&
            self.referenceNo == model.referenceNo &&
            isEqualDriverDetails &&
            isEqualTrailerDetails &&
            isEqualVehicleDetails &&
            isEqualNonEndorsableOffence &&

            self.getPenaltyType() == PenaltyType.value(from: model.penaltyType) &&
            self.getPaymentStatus()  == PaymentStatus.value(from: model.paymentStatus) &&
            self.paymentToken == model.paymentToken &&
            self.officerID == model.officerID &&
            self.siteCode == model.siteCode?.intValue &&
            UInt16(self.penaltyAmount) == model.penaltyAmount?.uint16Value &&

            self.paymentDueDate == model.paymentDueDate &&
            self.officerName == model.officerName &&
            self.placeWhereIssued == model.placeWhereIssued &&
            self.dateTime == model.dateTime &&
            self.paymentAuthCode == model.paymentAuthCode &&
            self.paymentDate == model.paymentDate
        return isEqualValue
    }
}

extension AWSDocumentModel {
    convenience init(object: DocumentObject) {
        self.init()

        self.penaltyType = object.getPenaltyType()?.toString()
        self.paymentStatus = object.getPaymentStatus()?.toString()
        self.paymentToken = object.paymentToken
        self.officerID = object.officerID
        self.siteCode = NSNumber(value: object.siteCode)
        self.formNo = object.formNo
        self.referenceNo = object.referenceNo
        self.driverDetails = object.driverDetails?.awsModel()
        self.trailerDetails = object.trailerDetails?.awsModel()
        self.vehicleDetails = object.vehicleDetails?.awsModel()
        self.nonEndorsableOffence = object.nonEndorsableOffence.map { (item) -> String in
            return item
        }
        if let penaltyAmount = UInt16(object.penaltyAmount) {
            self.penaltyAmount = NSNumber(value: penaltyAmount)
        } else {
            self.penaltyAmount = nil
        }
        self.paymentDueDate = object.paymentDueDate
        self.officerName = object.officerName
        self.placeWhereIssued = object.placeWhereIssued
        self.dateTime = object.dateTime
        self.paymentAuthCode = object.paymentAuthCode
        self.paymentDate = object.paymentDate
    }
}

extension DocumentObject {
    static func randomDocument() -> DocumentObject? {
        let model = AWSDocumentModel.generateRandomModel()
        return DocumentObject(model: model)
    }
}
