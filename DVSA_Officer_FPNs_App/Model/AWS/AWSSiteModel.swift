//
//  AWSSiteModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore

@objcMembers
public class AWSSiteModel: AWSModel {
    var name: String?
    var region: String?
    var siteCode: NSNumber?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["name"] = "name"
        params["region"] = "region"
        params["siteCode"] = "siteCode"
        return params
    }
}
