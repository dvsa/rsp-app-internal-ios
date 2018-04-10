//
//  Realm+Extensions.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

extension List where Element == BodyObject {

    func awsModel() -> [AWSBodyModel] {
        let value = self.reduce([AWSBodyModel](), { (result, bodyObject) -> [AWSBodyModel] in
            var newResult = result
            if let model = bodyObject.awsModel() {
                newResult.append(model)
            }
            return newResult
        })
        return value
    }
}

extension Results where Element == BodyObject {

    func awsModel() -> [AWSBodyModel] {
        let value = self.reduce([AWSBodyModel](), { (result, bodyObject) -> [AWSBodyModel] in
            var newResult = result
            if let model = bodyObject.awsModel() {
                newResult.append(model)
            }
            return newResult
        })
        return value
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        return flatMap { $0 as? T }
    }
}
