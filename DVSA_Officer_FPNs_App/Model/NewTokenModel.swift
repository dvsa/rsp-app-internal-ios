//
//  NewTokenModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class NewTokenModel: Model {
    var referenceNo: String = ""
    var penaltyType: PenaltyType = PenaltyType.fpn
    var vehicleRegNo: String = ""
    var penaltyAmount: String = ""
    var dateTime: Date?

    init(value: NewTokenModel?) {
        guard let value = value else {
            return
        }
        self.referenceNo = value.referenceNo
        self.penaltyType = value.penaltyType
        self.vehicleRegNo = value.vehicleRegNo
        self.penaltyAmount = value.penaltyAmount
        self.dateTime = value.dateTime
    }
}
