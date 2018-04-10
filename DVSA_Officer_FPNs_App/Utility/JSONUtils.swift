//
//  JSONUtils.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class JSONUtils {

    func loadJSONDictionary(resource: String) -> [String: Any]? {
        let bundle = Bundle(for: type(of: self))
        if let pathUrl = bundle.url(forResource: resource, withExtension: "json") {
            do {
                let data = try Data(contentsOf: pathUrl)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    return object
                } else {
                    print("JSON is invalid")
                }
            } catch {
                print("Error")
            }
        }
        return nil
    }

    func loadJSONDictionary(resource: String, with key: String) -> [String: Any]? {
        let bundle = Bundle(for: type(of: self))
        if let pathUrl = bundle.url(forResource: resource, withExtension: "json") {
            do {
                let data = try Data(contentsOf: pathUrl)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let json = json as? [String: Any],
                    let object = json[key] as? [String: Any] {
                    return object
                } else {
                    print("JSON is invalid")
                }
            } catch {
                print("Error")
            }
        }
        return nil
    }

    func loadJSONArray(resource: String, with key: String) -> [Any]? {
        let bundle = Bundle(for: type(of: self))
        if let pathUrl = bundle.url(forResource: resource, withExtension: "json") {
            do {
                let data = try Data(contentsOf: pathUrl)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let json = json as? [String: Any],
                    let object = json[key] as? [Any] {
                    return object
                } else {
                    print("JSON is invalid")
                }
            } catch {
                print("Error")
            }
        }
        return nil
    }
}
