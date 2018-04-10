//
//  ListModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

public protocol ListModel: Model {
    associatedtype Model = Any
    func all() -> [Model]
    func item(at index: Int) -> Model?
}
