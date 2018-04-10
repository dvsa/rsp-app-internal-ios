//
//  AWSNotifyEmailModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore

@objcMembers
public class AWSNotifyEmailModel: AWSModel {
    var email: String?
    var vehicleReg: String?
    var location: String?
    var amount: NSNumber?
    var token: String?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["email"] = "Email"
        params["vehicleReg"] = "VehicleReg"
        params["location"] = "Location"
        params["amount"] = "Amount"
        params["token"] = "Token"
        return params
    }

    func isValid() -> Bool {
        guard let email = email,
            vehicleReg != nil,
            location != nil,
            amount != nil,
            token != nil else {
            return false
        }
        return email.isValidEmail()
    }
}
