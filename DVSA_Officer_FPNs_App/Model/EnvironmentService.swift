//
//  EnvironmentService.swift
//  BaseProject
//
//  Created by Tim Walpole on 06/06/2016.
//  Copyright © 2016 BJSS Ltd. All rights reserved.
//

import UIKit
import Foundation

class EnvironmentService: NSObject {

    private static let infoPlistKey = "Custom Values"

    @objc static func getValueForKey(_ key: String!) -> String {
        let dict = getCustomValues()
        return dict?.object(forKey: key) as? String ?? ""
    }

    @objc static func getCustomValues() -> NSDictionary? {
        let path =  Bundle.main.path(forResource: "Info", ofType: "plist")
        var dict = NSDictionary(contentsOfFile: path!)
        dict = dict?.value(forKey: infoPlistKey) as? NSDictionary
        return dict
    }
}
