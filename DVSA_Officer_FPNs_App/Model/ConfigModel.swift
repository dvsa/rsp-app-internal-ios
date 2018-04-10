//
//  ConfigModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

struct ItemModel {
    let name: String
    let value: String
}

enum ConfigEnvironment: String {
    case dev = "DEV"
    case qa = "QA"
    case uat = "UAT"
    case perf = "PERF"
    case prod = "PROD"
}

class ConfigModel: ListModel {

    static let shared = ConfigModel()

    typealias Model = ItemModel

    internal var config: [ItemModel]

    init() {
        let environmentItem = ItemModel(name: "environment", value: ConfigModel.environment().rawValue)
        let bundleIdentifierItem = ItemModel(name: "bundleIdentifier", value: ConfigModel.bundleIdentifier() ?? "")
        config = [environmentItem, bundleIdentifierItem]

        let customValues = addCustomValues()
        config.append(contentsOf: customValues)
    }

    internal func addCustomValues() -> [ItemModel] {

        var values = [ItemModel]()
        if let dict = EnvironmentService.getCustomValues() {
            for (key, obj) in dict {
                if let name = key as? String,
                    let value = obj as? String {
                    let item = ItemModel(name: name, value: value)
                    values.append(item)
                }
            }
        }
        return values
    }

    internal func all() -> [ItemModel] {
        return config
    }

    internal func dictionary() -> [String: String] {
        var dictionary = [String: String]()
        self.all().forEach { (item) in
            dictionary[item.name] = item.value
        }
        return dictionary
    }

    internal func item(at index: Int) -> ItemModel? {
       return self.all()[index]
    }

    internal func item(for name: String) -> ItemModel? {
        let item = self.config.first { (item) -> Bool in
            return item.name == name
        }
        return item
    }

    static func environment() -> ConfigEnvironment {

        var environment: ConfigEnvironment = .prod

        #if DEV
            environment = .dev
        #endif

        #if QA
            environment = .qa
        #endif

        #if UAT
            environment = .uat
        #endif

        #if PERF
            environment = .perf
        #endif

        return environment
    }

    static func bundleIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }
}
