//
//  SiteObject.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 04/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

enum SiteRegion: String {
    case northern = "Northern"
    case southEast = "South East"
    case western = "Western"
    case eastern = "Eastern"
    case mobile = "Mobile"
    case unknown = ""

    func predicate() -> NSPredicate {
        return NSPredicate(format: "region == \(self.rawValue)")
    }
}

class SiteObject: Object, ModelWithKey {

    @objc dynamic var name: String = ""
    @objc dynamic var code: Int = 0
    @objc dynamic var region: String = SiteRegion.unknown.rawValue

    override public class func primaryKey() -> String? {
        return "code"
    }

    convenience init?(model: AWSSiteModel) {

        guard let name = model.name,
            let code = model.siteCode?.intValue,
            let region = model.region,
            let regionType = SiteRegion(rawValue: region)
            else {
                return nil
        }
        self.init()
        self.name = name
        self.region = regionType.rawValue
        self.code = code
    }

    func awsModel() -> AWSSiteModel? {
        return AWSSiteModel(object: self)
    }

    func key() -> Int {
        return code
    }
}

extension AWSSiteModel {
    convenience init(object: SiteObject) {
        self.init()
        self.name = object.name
        self.region = object.region
        self.siteCode = NSNumber(value: object.code)
    }
}
