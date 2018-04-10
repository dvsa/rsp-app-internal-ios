//
//  PersistentBodyDataSource.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

protocol DataSourceDelegate: class {
    func didChanged()
}

protocol ObjectsDataSource {
    func list() -> [BodyObject]?
    func sites() -> [SiteObject]?
    func observe(completion: @escaping ([BodyObject]?) -> Void) -> NotificationToken?
    func observeSites(completion: @escaping ([SiteObject]?) -> Void) -> NotificationToken?
    func item(for key: String) -> BodyObject?
    func insert(item: BodyObject) throws
    func update(item: BodyObject) throws
    func delete(item: BodyObject) throws
    func clean() throws
    func maxOffset() -> TimeInterval?
    func hideNotification(for key: String) throws
    func hideOverridden(for key: String) throws
    func updateSite(from resource: String)
    func removeExpiredDocuments(offset: TimeInterval) throws
}

class PersistentDataSource: ObjectsDataSource {

    var configuration = Realm.Configuration.defaultConfiguration

    func maxOffset() -> TimeInterval? {
        let realm = try? Realm(configuration: self.configuration)
        let predicate = NSPredicate(format: "hashToken != 'New'")
        let bodies = realm?.objects(BodyObject.self).filter(predicate)
        let offset = bodies?.max(ofProperty: "offset") as Date?
        log.verbose("realm bodies.count: \(bodies?.count ?? 0)")
        log.verbose("maxOffset: \(String(describing: offset))")
        return offset?.timeIntervalSince1970
    }

    func list() -> [BodyObject]? {
        let realm = try? Realm(configuration: self.configuration)
        let items = realm?.objects(BodyObject.self).sorted(byKeyPath: "offset", ascending: false).toArray(ofType: BodyObject.self)
        return items
    }

    func sites() -> [SiteObject]? {
        let realm = try? Realm(configuration: self.configuration)
        let items = realm?.objects(SiteObject.self).sorted(byKeyPath: "name", ascending: true).toArray(ofType: SiteObject.self)
        return items
    }

    func updateSite(from resource: String) {
        let siteListDictionary = JSONUtils().loadJSONDictionary(resource: resource)
        let siteListAdapter = AWSMTLJSONAdapter(jsonDictionary: siteListDictionary, modelClass: AWSSiteListModel.self)
        guard let model = siteListAdapter?.model as? AWSSiteListModel else {
            log.error("Unable to update sites from resource")
            return
        }

        do {
            guard let items = model.items else {
                return
            }
            let realm = try Realm(configuration: self.configuration)
            try realm.write {
                for item in items {
                    guard let siteObject = SiteObject(model: item) else {
                        continue
                    }
                    realm.add(siteObject, update: true)
                }
            }
        } catch {
        }
    }

    func observe(completion: @escaping ([BodyObject]?) -> Void) -> NotificationToken? {
        let realm = try? Realm(configuration: self.configuration)
        let results = realm?.objects(BodyObject.self)
        return results?.observe { [weak self] (changes: RealmCollectionChange) in

            switch changes {
            case .initial:
                let items = self?.list()
                completion(items)
            case .update:
                let items = self?.list()
                completion(items)
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                completion(nil)
                fatalError("\(error)")
            }
        }
    }

    func observeSites(completion: @escaping ([SiteObject]?) -> Void) -> NotificationToken? {
        let realm = try? Realm(configuration: self.configuration)
        let results = realm?.objects(SiteObject.self)
        return results?.observe { [weak self] (changes: RealmCollectionChange) in

            switch changes {
            case .initial:
                let items = self?.sites()
                completion(items)
            case .update:
                let items = self?.sites()
                completion(items)
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                completion(nil)
                fatalError("\(error)")
            }
        }
    }

    func item(for key: String) -> BodyObject? {
        let realm = try? Realm(configuration: self.configuration)
        return realm?.object(ofType: BodyObject.self, forPrimaryKey: key)
    }

    func insert(item: BodyObject) throws {

        let realm = try Realm(configuration: self.configuration)
        try realm.write {
            if let oldBody = realm.object(ofType: BodyObject.self, forPrimaryKey: item.key) {
                if oldBody.enabled {
                    throw DataSourceError.duplicateKey
                } else {
                    item.hashToken = oldBody.hashToken
                }
            }
            item.status = SynchStatusType.pending.rawValue
            realm.add(item, update: true)
        }
    }

    func update(item: BodyObject) throws {

        let realm = try Realm(configuration: self.configuration)
        try realm.write {
            item.status = SynchStatusType.pending.rawValue
            realm.add(item, update: true)
        }
    }

    func delete(item: BodyObject) throws {

        let realm = try Realm(configuration: self.configuration)
        try realm.write {
            item.enabled = false
            item.status = SynchStatusType.pending.rawValue
            realm.add(item, update: true)
        }
    }

    func clean() throws {
        let realm = try Realm(configuration: self.configuration)
        let bodyToDelete = realm.objects(BodyObject.self)
        let documentToDelete = realm.objects(DocumentObject.self)
        let vehicleDetailsToDelete = realm.objects(VehicleDetailsObject.self)
        let trailerToDelete = realm.objects(TrailerDetailsObject.self)
        let driverDetailToDelete = realm.objects(DriverDetailsObject.self)
        try realm.write {
            realm.delete(bodyToDelete)
            realm.delete(documentToDelete)
            realm.delete(vehicleDetailsToDelete)
            realm.delete(trailerToDelete)
            realm.delete(driverDetailToDelete)
        }
    }

    func removeExpiredDocuments(offset: TimeInterval) throws {
        let realm = try Realm(configuration: self.configuration)
        let date = Date.todayUTC.addingTimeInterval(-offset)
        let predicate = NSPredicate(format: "offset <= %@", date as CVarArg)
        let objectsToDelete = realm.objects(BodyObject.self).filter(predicate)
        try realm.write {
            for bodyToDelete in objectsToDelete {
                if let document = bodyToDelete.value {
                    if let driverDetails = document.driverDetails {
                        realm.delete(driverDetails)
                    }
                    if let vehicleDetails = document.vehicleDetails {
                        realm.delete(vehicleDetails)
                    }
                    if let trailerDetails = document.trailerDetails {
                        realm.delete(trailerDetails)
                    }
                    realm.delete(document)
                }
                realm.delete(bodyToDelete)
            }
            log.info("Removed \(objectsToDelete.count) Expired Documents with date <= \(date)")
        }
    }

    func hideNotification(for key: String) throws {
        let realm = try Realm(configuration: self.configuration)
        if let bodyObject = realm.object(ofType: BodyObject.self, forPrimaryKey: key) {
            try realm.write {
                bodyObject.hideNotification = true
                realm.add(bodyObject, update: true)
            }
        }
    }

    func hideOverridden(for key: String) throws {
        let realm = try Realm(configuration: self.configuration)
        if let bodyObject = realm.object(ofType: BodyObject.self, forPrimaryKey: key) {
            try realm.write {
                bodyObject.value?.overridden = false
                realm.add(bodyObject, update: true)
            }
        }
    }
}
