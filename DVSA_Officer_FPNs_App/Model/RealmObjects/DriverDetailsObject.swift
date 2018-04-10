//
//  DriverDetailsObject.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

class DriverDetailsObject: Object, Model {

    @objc dynamic var name: String?
    @objc dynamic var address: String?
    @objc dynamic var licenceNumber: String?

    convenience init?(model: AWSDriverDetailsModel) {
        self.init()
        self.name = model.name
        self.address = model.address
        self.licenceNumber = model.licenceNumber
    }

    func awsModel() -> AWSDriverDetailsModel? {
        return AWSDriverDetailsModel(object: self)
    }

    func isEqualToModel(model: AWSDriverDetailsModel) -> Bool {
        return self.address == model.address &&
            self.licenceNumber == model.licenceNumber &&
            self.name == model.name
    }
}

extension AWSDriverDetailsModel {
    convenience init(object: DriverDetailsObject) {
        self.init()
        self.name = object.name
        self.address = object.address
        self.licenceNumber = object.licenceNumber
    }
}
