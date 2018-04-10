//
//  DoneMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 02/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class TestDone {
    internal var done = [String: Bool]()
    func reset() {
        done = [String: Bool]()
    }

}

extension TestDone {

    subscript (_ key: String) -> Bool {
        get {
            if let value = self.done[key] {
                return value
            }
            return false
        }

        set (newValue) {
            self.done[key] = newValue
        }
    }
}
