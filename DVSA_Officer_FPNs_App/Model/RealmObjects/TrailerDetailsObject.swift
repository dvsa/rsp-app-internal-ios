//
//  TrailerDetailsObject.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

class TrailerDetailsObject: Object, Model {

    @objc dynamic var number1: String?
    @objc dynamic var number2: String?

    convenience init?(model: AWSTrailerDetailsModel) {
        self.init()
        self.number1 = model.number1
        self.number2 = model.number2
    }

    func awsModel() -> AWSTrailerDetailsModel? {
        return AWSTrailerDetailsModel(object: self)
    }

    func isEqualToModel(model: AWSTrailerDetailsModel) -> Bool {
        return self.number2 == model.number2 &&
            self.number1 == model.number1
    }
}

extension AWSTrailerDetailsModel {
    convenience init(object: TrailerDetailsObject) {
        self.init()
        self.number1 = object.number1
        self.number2 = object.number2
    }
}
