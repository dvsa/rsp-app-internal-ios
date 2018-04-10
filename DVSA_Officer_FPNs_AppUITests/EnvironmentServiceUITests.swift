//
//  EnvironmentServiceUITests.swift
//  DVSA_Officer_FPNs_AppUITests
//
//  Created by Andrea Scuderi on 01/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import Foundation

class EnvironmentServiceUITests: NSObject {

    private static let infoPlistKey = "Custom Values"

    static func getValueForKey(_ key: String!) -> String {
        let dict = getCustomValues()
        return dict?.object(forKey: key) as? String ?? ""
    }

    static func getCustomValues() -> NSDictionary? {
        let testBundle = Bundle(for: DVSAOfficerFPNsAppUITests.self)
        if let path =  testBundle.path(forResource: "UITestsConfig", ofType: "plist") {
            let dict = NSDictionary(contentsOfFile: path)
            return dict
        }
        return nil
    }
}
