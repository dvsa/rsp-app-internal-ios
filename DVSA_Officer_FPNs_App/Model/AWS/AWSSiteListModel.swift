//
//  AWSSiteListModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore

@objcMembers
public class AWSSiteListModel: AWSModel, ListModel {

    public typealias Model = AWSSiteModel

    var items: [AWSSiteModel]?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["items"] = "Items"
        return params
    }

    public static func itemsJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: AWSSiteModel.self)
    }

    public func all() -> [AWSSiteModel] {
        return items ?? [AWSSiteModel]()
    }

    public func item(at index: Int) -> AWSSiteModel? {
        return items?[index]
    }

    public func remove(at index: Int) -> AWSSiteModel? {
        return items?.remove(at: index)
    }

    public func update(at index: Int, item: AWSSiteModel) {
        if items == nil {
            items = [AWSSiteModel]()
        }
        let count = items?.count ?? 0
        if index < count {
            items?[index] = item
        } else {
            items?.append(item)
        }
    }
}
