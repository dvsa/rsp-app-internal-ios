//
//  AWSTrailerDetailsModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore

@objcMembers
public class AWSTrailerDetailsModel: AWSModel {
    var number1: String?
    var number2: String?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["number1"] = "number1"
        params["number2"] = "number2"
        return params
    }
}
