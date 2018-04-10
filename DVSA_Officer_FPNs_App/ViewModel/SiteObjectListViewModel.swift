//
//  SiteObjectListViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 08/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class SiteObjectListViewModel: ListViewModel<SiteObjectList> {

    var datasource: ObjectsDataSource

    internal var isMobile: Bool = false

    func update(items: [SiteObject]) {
        if isMobile {
            self.model.items = items.filter { (site) -> Bool in
                site.region == SiteRegion.mobile.rawValue
            }
        } else {
            self.model.items = items.filter { (site) -> Bool in
                site.region != SiteRegion.mobile.rawValue
            }
        }
    }

    init(datasource: ObjectsDataSource, isMobile: Bool) {
        self.isMobile = isMobile
        self.datasource = datasource
        let model = SiteObjectList()
        if let items = datasource.sites() {
            if isMobile {
                model.items = items.filter { (site) -> Bool in
                    site.region == SiteRegion.mobile.rawValue
                }
            } else {
                model.items = items.filter { (site) -> Bool in
                    site.region != SiteRegion.mobile.rawValue
                }
            }
        } else {
            model.items = [SiteObject]()
        }
        super.init(model: model)
    }
}
