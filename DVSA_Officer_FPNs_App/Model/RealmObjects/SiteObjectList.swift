//
//  SiteObjectList.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class SiteObjectList: ListModel {

    typealias Model = SiteObject

    var items: [SiteObject]?

    func all() -> [SiteObject] {
        return items ?? [SiteObject]()
    }

    func item(at index: Int) -> SiteObject? {
        return items?[index]
    }
}
