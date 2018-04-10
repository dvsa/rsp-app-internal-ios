//
//  NewTokenDetailsViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

enum NewTokenDetailsViewModelError: LocalizedError {
    case invalidToken
    case invalidBodyModel
    case realmError

    public var failureReason: String? {
        switch self {
        case .invalidToken:
            return "Unable to create payment code"
        case .invalidBodyModel:
            return "Unable to create the payment code"
        case .realmError:
            return "Unable to create the payment code"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Configuration error"
        case .invalidBodyModel:
            return "Internal error"
        case .realmError:
            return "Internal error"
        }
    }
}

class NewTokenDetailsViewModel: Model {
    internal var model: BodyObject
    var token: String

    var preferences: PreferencesDataSourceProtocol
    var datasource: ObjectsDataSource

    init(model: NewTokenModel,
         preferences: PreferencesDataSourceProtocol,
         datasource: ObjectsDataSource,
         key: [UInt32]) throws {

        self.preferences = preferences
        self.datasource = datasource
        let document = DocumentObject()

        document.dateTime = model.dateTime
        document.setKey(referenceNo: model.referenceNo, penaltyType: model.penaltyType)
        document.vehicleDetails = VehicleDetailsObject()
        document.vehicleDetails?.regNo = model.vehicleRegNo
        document.penaltyAmount = model.penaltyAmount
        document.setPaymentStatus(paymentStatus: .unpaid)
        guard let token = PaymentToken(document: document)?.encryptedToken(key: key),
            let siteCode = preferences.site()?.code,
            let officerID = preferences.userID,
            let officerName = preferences.username else {
                throw NewTokenDetailsViewModelError.invalidToken
        }
        if let userPreferences = preferences.userPreferences() {
            if userPreferences.isMobile {
                document.placeWhereIssued = preferences.userPreferences()?.mobileAddress ?? " - "
            } else {
                document.placeWhereIssued = preferences.site()?.name ?? " - "
            }
        } else {
            document.placeWhereIssued = " - "
        }
        document.paymentToken = token
        document.siteCode = siteCode
        document.officerID = officerID
        document.officerName = officerName
        guard let body = BodyObject(object: document) else {
            throw NewTokenDetailsViewModelError.invalidBodyModel
        }
        try datasource.insert(item: body)
        self.model = body
        self.token = token
    }

    var isSynchronized: Bool = false

    var sharableToken: String {
        return self.token.insert(separator: "-", lenght: 4)
    }
}
