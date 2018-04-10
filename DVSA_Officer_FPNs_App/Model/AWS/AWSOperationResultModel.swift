//
//  AWSOperationResultModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 27/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import AWSCore

@objcMembers
public class AWSOperationResultModel: AWSModel {
    var item: AWSBodyModel?
    var status: NSNumber?
    var error: NSDictionary?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["item"] = "item"
        params["status"] = "status"
        params["error"] = "error"
        return params
    }

    public static func itemJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONDictionaryTransformer(withModelClass: AWSBodyModel.self)
    }
}

@objcMembers
public class AWSOperationResultListModel: AWSModel, ListModel {

    public typealias Model = AWSOperationResultModel

    var items: [AWSOperationResultModel]?

    public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        var params: [AnyHashable: Any] = [:]
        params["items"] = "Items"
        return params
    }

    public static func itemsJSONTransformer() -> ValueTransformer {
        return AWSMTLValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: AWSOperationResultModel.self)
    }

    public func all() -> [AWSOperationResultModel] {
        return items ?? [AWSOperationResultModel]()
    }

    public func item(at index: Int) -> AWSOperationResultModel? {
        return items?[index]
    }
}

extension AWSOperationResultListModel {

    func toOpResultItems() -> OpResultItems<AWSBodyModel> {
        let items = self.all().reduce( [OpResultItem<AWSBodyModel>]()) { (result, modelItem) -> [OpResultItem<AWSBodyModel>] in
            var newResult = result
            if let item = modelItem.item,
                let status = modelItem.status?.intValue {
                let item = OpResultItem<AWSBodyModel>(item: item, succeded: status == 200)
                newResult.append(item)
            }
            return newResult
        }
        return OpResultItems<AWSBodyModel>(items: items)
    }
}
