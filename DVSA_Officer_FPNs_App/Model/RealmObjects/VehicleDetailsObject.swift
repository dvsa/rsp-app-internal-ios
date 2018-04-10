//
//  VehicleDetailsObject.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

class VehicleDetailsObject: Object, Model {

    @objc dynamic var regNo: String = ""
    @objc dynamic var make: String?
    @objc dynamic var nationality: String?

    convenience init?(model: AWSVehicleDetailsModel) {
        guard let regNo = model.regNo else {

                return nil
        }
        self.init()
        self.regNo = regNo
        self.make = model.make
        self.nationality = model.nationality
    }

    func awsModel() -> AWSVehicleDetailsModel? {
        return AWSVehicleDetailsModel(object: self)
    }

    func isEqualToModel(model: AWSVehicleDetailsModel) -> Bool {
        return self.regNo == model.regNo &&
            self.make == model.make &&
            self.nationality == model.nationality
    }
}

extension AWSVehicleDetailsModel {
    convenience init(object: VehicleDetailsObject) {
        self.init()
        self.regNo = object.regNo
        self.make = object.make
        self.nationality = object.nationality
    }
}
