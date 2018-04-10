//
//  AWSVehicleDetailsModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore

@objcMembers
public class AWSVehicleDetailsModel: AWSModel {
    var regNo: String?
    var make: String?
    var nationality: String?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["regNo"] = "regNo"
        params["make"] = "make"
        params["nationality"] = "nationality"
        return params
    }
}
