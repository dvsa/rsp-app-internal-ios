//
//  TokenDetailsViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class TokenDetailsViewModel: Model {
    internal var model: BodyObject

    let title: String
    var titleTextColor: UIColor
    let isPaid: Bool
    var isEnabled: Bool
    let registrationNo: String
    var paymentStatus: String
    let paymentToken: String
    let notifyStatus: String
    let referenceNo: String
    let penaltyAmount: String
    let siteLocation: String
    let penaltyType: String
    let penaltyDate: String
    let paymentDate: String
    let authorizationCode: String

    init(model: BodyObject) {
        self.model = model

        let document = model.value
        let paymentStatusValue = document?.getPaymentStatus() ?? .unpaid
        title = "Payment code for \(document?.vehicleDetails?.regNo ?? " - ")"
        titleTextColor = model.enabled ? .black : .dvsaRed
        isPaid = (paymentStatusValue == .paid)
        isEnabled = model.enabled
        registrationNo = "Reg: \(document?.vehicleDetails?.regNo ?? " - ")"
        paymentStatus = model.enabled ? paymentStatusValue.toString() : "Cancelled"
        paymentToken = document?.paymentToken?.insert(separator: "-", lenght: 4) ?? ""
        notifyStatus = ""
        referenceNo = document?.referenceNo ?? ""
        penaltyAmount = "£\(document?.penaltyAmount ?? "0")"
        siteLocation = document?.placeWhereIssued?.truncated(limit: 25) ?? ""
        penaltyType = document?.getPenaltyType()?.toExtendedString() ?? ""
        penaltyDate = document?.dateTime?.dvsaDateString ?? ""
        paymentDate = document?.paymentDate?.dvsaDateTimeString ?? " - "
        authorizationCode = document?.paymentAuthCode ?? " - "
    }

    internal func setDisabled() {
        isEnabled = false
        titleTextColor = .dvsaRed
        paymentStatus = "Cancelled"
    }

}
