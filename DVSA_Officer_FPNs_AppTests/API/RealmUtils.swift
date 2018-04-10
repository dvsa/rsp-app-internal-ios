//
//  SynchronizationManager+Extension.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 22/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
@testable import DVSA_Officer_FPNs_App

class RealmUtils {

    static func setupTest(name: String) -> Realm.Configuration? {
        do {
            let directory = URL(fileURLWithPath: RLMRealmPathForFile("default.realm")).deletingLastPathComponent().appendingPathComponent("RealmTest")
            let attributes = [FileAttributeKey.protectionKey: FileProtectionType.none]
            try FileManager.default.createDirectory(at: directory,
                                                    withIntermediateDirectories: true, attributes: attributes)

            let file = directory.appendingPathComponent(name).path

            let fileURL = URL(fileURLWithPath: file, isDirectory: false)
            log.debug(fileURL)
            return Realm.Configuration(fileURL: fileURL)
        } catch {
            return nil
        }
    }

    static func removeTest(name: String) {
        let directory = URL(fileURLWithPath: RLMRealmPathForFile("default.realm")).deletingLastPathComponent().appendingPathComponent("RealmTest")
        let realmURL = directory.appendingPathComponent(name)
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management"),
            directory
        ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
                log.debug("Removed \(URL)")
            } catch let error {
                log.error(error)
            }
        }
    }
}
