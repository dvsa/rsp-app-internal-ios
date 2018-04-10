//
//  AWSBodyModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore

@objcMembers
public class AWSBodyModel: AWSModel {
    var key: String?
    var value: AWSDocumentModel?
    var hashToken: String?
    var offset: Date?
    var enabled: NSNumber?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["key"] = "ID"
        params["value"] = "Value"
        params["hashToken"] = "Hash"
        params["offset"] = "Offset"
        params["enabled"] = "Enabled"
        return params
    }

    public static func valueJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONDictionaryTransformer(withModelClass: AWSDocumentModel.self)
    }

    public static func offsetJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.timeIntervalSince1970JSONTransformer()
    }

}
