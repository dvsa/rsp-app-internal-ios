//
//  AWSNextIndexModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

@objcMembers
public class AWSNextIndexModel: AWSModel {

    var nextID: String?
    var nextOffset: Date?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["nextID"] = "ID"
        params["nextOffset"] = "Offset"
        return params
    }

    public static func nextOffsetJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.timeIntervalSince1970JSONTransformer()
    }
}
