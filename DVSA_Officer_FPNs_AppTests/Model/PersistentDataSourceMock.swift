//
//  PersistentDataSourceMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 06/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RealmSwift

@testable import DVSA_Officer_FPNs_App

class PersistentDataSourceMock: ObjectsDataSource {

    var done = TestDone()

    var listObjects: [BodyObject]?
    var sitesObjects: [SiteObject]?
    var itemObject: BodyObject?

    var filterOptions: NSPredicate?
    var maxOffsetMock: TimeInterval?

    func maxOffset() -> TimeInterval? {
        return maxOffsetMock
    }

    func list() -> [BodyObject]? {
        done["list"] = true
        return listObjects
    }

    func sites() -> [SiteObject]? {
        done["sites"] = true
        return sitesObjects
    }

    func updateSite(from resource: String) {
        done["updateSite"] = true
    }

    func observe(completion: @escaping ([BodyObject]?) -> Void) -> NotificationToken? {
        done["observe"] = true
        completion(listObjects)
        return nil
    }

    func observeSites(completion: @escaping ([SiteObject]?) -> Void) -> NotificationToken? {
        done["observeSites"] = true
        completion(sitesObjects)
        return nil
    }

    func item(for key: String) -> BodyObject? {
        done["item"] = true
        return itemObject
    }

    func insert(item: BodyObject) throws {
        done["insert"] = true
        self.itemObject = item
        return
    }

    func update(item: BodyObject) throws {
        done["update"] = true
        self.itemObject = item
        return
    }

    func delete(item: BodyObject) throws {
        done["delete"] = true
        self.itemObject = nil
        return
    }

    func clean() throws {
        done["clean"] = true
        self.itemObject = nil
        self.listObjects = nil
        return
    }

    func hideNotification(for key: String) throws {
        done["hideNotification"] = true
        self.itemObject?.hideNotification = true
        return
    }

    func hideOverridden(for key: String) throws {
        done["hideOverridden"] = true
        self.itemObject?.value?.overridden  = false
        return
    }

    func removeExpiredDocuments(offset: TimeInterval) throws {
        done["removeExpiredDocuments"] = true
    }
}
