//
//  AWSBodyListModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 27/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore

@objcMembers
public class AWSBodyListModel: AWSModel, ListModel {

    public typealias Model = AWSBodyModel

    var items: [AWSBodyModel]?
    var nextOperation: AWSNextIndexModel?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["items"] = "Items"
        params["nextOperation"] = "LastEvaluatedKey"
        return params
    }

    public static func itemsJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: AWSBodyModel.self)
    }

    public static func nextOperationJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONDictionaryTransformer(withModelClass: AWSNextIndexModel.self)
    }

    public func all() -> [AWSBodyModel] {
        return items ?? [AWSBodyModel]()
    }

    public func item(at index: Int) -> AWSBodyModel? {

        let max = items?.count ?? 0
        guard items != nil,
            index < max,
            index >= 0 else {
                return nil
        }
        return items?[index]
    }
}
