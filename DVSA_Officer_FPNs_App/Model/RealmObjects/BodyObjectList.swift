//
//  BodyObjectList.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 18/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class BodyObjectList: ListModel {

    typealias Model = BodyObject

    var items: [BodyObject]?

    func all() -> [BodyObject] {
        return items ?? [BodyObject]()
    }

    func item(at index: Int) -> BodyObject? {

        let max = items?.count ?? 0
        guard items != nil,
            index < max,
            index >= 0 else {
            return nil
        }
        return items?[index]
    }
}
