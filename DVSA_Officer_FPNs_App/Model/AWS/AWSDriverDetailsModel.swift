//
//  AWSDriverDetailsModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

@objcMembers
public class AWSDriverDetailsModel: AWSModel {
    var name: String?
    var address: String?
    var licenceNumber: String?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["name"] = "name"
        params["address"] = "address"
        params["licenceNumber"] = "licenceNumber"
        return params
    }
}
