//
//  Model.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import AWSCore

public protocol Model {

}

extension AWSModel: Model {

}

public protocol ModelWithKey: Model {
    func key() -> Int
}
