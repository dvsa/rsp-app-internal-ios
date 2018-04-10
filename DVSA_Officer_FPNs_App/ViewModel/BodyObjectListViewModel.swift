//
//  BodyObjectListViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 18/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class BodyObjectListViewModel: ListViewModel<BodyObjectList> {

    var datasource: ObjectsDataSource

    init(datasource: ObjectsDataSource) {
        self.datasource = datasource
        let model = BodyObjectList()
        if let items = datasource.list() {
            model.items = items
        } else {
            model.items = [BodyObject]()
        }
        super.init(model: model)
    }

    init(datasource: ObjectsDataSource, filterOptions: (BodyObject) -> Bool) {
        self.datasource = datasource
        let model = BodyObjectList()
        if let items = datasource.list() {
            model.items = items.filter(filterOptions)
        } else {
            model.items = [BodyObject]().filter(filterOptions)
        }
        super.init(model: model)
    }
}
