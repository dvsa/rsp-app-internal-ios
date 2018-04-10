//
//  SynchronizationManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 13/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

protocol SynchronizationDelegate: class {
    func delete(item: AWSBodyModel, completion:@escaping (Bool) -> Void)
    func uploadPending(items: [AWSBodyModel], completion:@escaping (Bool) -> Void)
    func download(completion:@escaping (Bool) -> Void)
    func synchronize(completion:@escaping (Bool) -> Void) throws
    func isSyncRequired() -> Bool
    func sites(completion:@escaping (Bool) -> Void)
    static func getKey() -> Data
    var lastUpdate: Date? { get set }
}

extension Notification.Name {
    public static let DidReceiveAPIUpdate = Notification.Name("AWSSNSDidReceiveDBUpdate")
}

class SynchronizationManager: ReachabilityObserverDelegate {

    static let shared = SynchronizationManager()

    lazy var reachabilityObserver = ReachabilityObserver(name: "SynchronizationManager", delegate: self)

    let kLastUpdate = "kRoadsidePaymentLastUpdate"

    var datamanager: BaseAPIDataManager = APIDataManager.shared
    var configuration = Realm.Configuration.defaultConfiguration
    var nextIndexDatasource: NextIndexDatasource = LocalNextIndexDatasource()

    init() {
        reachabilityObserver.startObserveReachability()
    }

    deinit {
        reachabilityObserver.stopObserveReachability()
    }

    func reachabilityDidChange(isReachable: Bool) {
        if isReachable && isSyncRequired() {
            try? self.synchronize { (success) in
                if success {
                    log.info("sync succeded")
                } else {
                    log.error("sync error")
                }
            }
        }
    }
}

extension SynchronizationManager: SynchronizationDelegate {

    func delete(item: AWSBodyModel, completion:@escaping (Bool) -> Void) {
        datamanager.delete(item: item) { (removed) in
            autoreleasepool {
                guard let removed = removed else {
                    completion(false)
                    return
                }
                do {
                    let realm = try Realm(configuration: self.configuration)
                    try realm.write {
                        if let bodyObject = BodyObject(model: removed) {
                            bodyObject.status = SynchStatusType.updated.rawValue
                            realm.add(bodyObject, update: true)
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                } catch {
                   completion(false)
                }
            }
        }
    }

    func uploadPending(items: [AWSBodyModel], completion:@escaping (Bool) -> Void) {
        datamanager.update(items: items) { (opResults) in
            autoreleasepool {
                do {
                    var status = false
                    let realm = try? Realm(configuration: self.configuration)
                    try realm?.write {
                        guard let results = opResults?.items else {
                            completion(false)
                            return
                        }
                        for result in results {
                            guard result.item.key != nil else {
                                continue
                            }
                            let status = result.succeded ? SynchStatusType.updated : SynchStatusType.conflicted
                            if let bodyObject = BodyObject(model: result.item) {
                                bodyObject.status = status.rawValue
                                let oldBodyObject = realm?.object(ofType: BodyObject.self, forPrimaryKey: bodyObject.key)
                                if oldBodyObject?.value?.paymentToken != bodyObject.value?.paymentToken {
                                    bodyObject.value?.overridden = true
                                } else {
                                    bodyObject.value?.overridden = oldBodyObject?.value?.overridden ?? false
                                }
                                realm?.add(bodyObject, update: true)
                            }
                        }
                        status = true
                    }
                    completion(status)
                } catch {
                    completion(false)
                }
            }
        }
    }

    func download(completion:@escaping (Bool) -> Void) {

        datamanager.list(datasource: nextIndexDatasource) { (items) in
            autoreleasepool {
                self.lastUpdate = Date()
                do {
                    guard let items = items else {
                        log.verbose("Downloaded items result is nil")
                        completion(false)
                        return
                    }
                    log.verbose("Downloaded \(items.count) items")

                    let realm = try? Realm(configuration: self.configuration)
                    try realm?.write {
                        for item in items {
                            guard let bodyObject = BodyObject(model: item) else {
                                log.error("Unable to decode \(item.description())")
                                continue
                            }
                            let oldBodyObject = realm?.object(ofType: BodyObject.self, forPrimaryKey: bodyObject.key)
                            if let oldBodyObject = oldBodyObject {
                                if oldBodyObject.status != SynchStatusType.pending.rawValue {

                                    if oldBodyObject.hashToken != bodyObject.hashToken ||
                                        oldBodyObject.offset != bodyObject.offset {
                                        bodyObject.hideNotification = false
                                    } else {
                                        bodyObject.hideNotification = oldBodyObject.hideNotification
                                    }

                                    if oldBodyObject.value?.paymentToken != bodyObject.value?.paymentToken {
                                        bodyObject.value?.overridden = true
                                    } else {
                                        bodyObject.value?.overridden = oldBodyObject.value?.overridden ?? false
                                    }

                                    realm?.add(bodyObject, update: true)
                                    #if DEBUG
                                    log.verbose("Added \(bodyObject.description)")
                                    #endif
                                }
                            } else {
                                realm?.add(bodyObject, update: false)
                                #if DEBUG
                                log.verbose("Added \(bodyObject.description)")
                                #endif
                            }
                        }
                    }
                    completion(true)
                } catch {
                    completion(false)
                }
            }
        }
    }

    func isSyncRequired() -> Bool {
        guard let realm = try? Realm(configuration: self.configuration) else {
            return false
        }
        let predicate = SynchStatusType.pending.predicate()
        let pendingTable = realm.objects(BodyObject.self).filter(predicate)
        let isPending = pendingTable.count > 0
        return isPending
    }

    func synchronize(completion:@escaping (Bool) -> Void) throws {

        guard let realm = try? Realm(configuration: self.configuration) else {
            completion(false)
            return
        }

        let predicates = [SynchStatusType.conflicted.predicate(),
                          SynchStatusType.pending.predicate()]

        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: predicates)

        let pendingTable = realm.objects(BodyObject.self).filter(compoundPredicate)
        if pendingTable.count > 0 {
            let pendingItems = pendingTable.awsModel()
            self.uploadPending(items: pendingItems) { [weak self] _ in
                self?.download(completion: completion)
            }
        } else {
            self.download(completion: completion)
        }
    }

    func sites(completion:@escaping (Bool) -> Void) {
        datamanager.sites { (items) in
            autoreleasepool {
                do {
                    guard let items = items else {
                        completion(false)
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
                    completion(true)
                } catch {
                    completion(false)
                }
            }
        }
    }

    static func getKey() -> Data {
        if let currentKey = getKeyIfAvailable() {
            removeKey()
            addKey(data: currentKey as AnyObject)
            return currentKey
        }
        guard let newKey = generateNewKey() else {
            exit(0)
        }
        addKey(data: newKey as AnyObject)
        return newKey as Data
    }

    private static func getKeyIfAvailable() -> Data? {
        let keychainIdentifier = "\(ConfigModel.bundleIdentifier()!).RealmEncryptionKey"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!

        let query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]

        // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
        // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [:])
        log.warning(error)
        return nil
    }

    private static func generateNewKey() -> Data? {
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        if result != 0 {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(result), userInfo: [:])
            log.severe(error)
            log.severe("Failed to get random bytes")
            return nil
        }
        return keyData as Data
    }

    private static func addKey(data: AnyObject) {

        let keychainIdentifier = "\(ConfigModel.bundleIdentifier()!).RealmEncryptionKey"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [:])
            log.severe(error)
            log.severe("Failed to insert the new key in the keychain")
            exit(0)
        }
    }

    private static func removeKey() {

        let keychainIdentifier = "\(ConfigModel.bundleIdentifier()!).RealmEncryptionKey"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!

        let query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecUseOperationPrompt: kSecUseAuthenticationContext
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [:])
            log.error(error)
        }
    }

    static func setup() {
        autoreleasepool {
            do {
                let directory = URL(fileURLWithPath: RLMRealmPathForFile("default.realm")).deletingLastPathComponent().appendingPathComponent("Realm")
                let attributes = [FileAttributeKey.protectionKey: FileProtectionType.none]
                try FileManager.default.createDirectory(at: directory,
                                                        withIntermediateDirectories: true, attributes: attributes)

                let file = directory.appendingPathComponent("default.realm").path

                let fileURL = URL(fileURLWithPath: file, isDirectory: false)
                var configuration = Realm.Configuration(fileURL: fileURL, encryptionKey: SynchronizationManager.getKey())
                //TODO : Dangerous it can loose stored tokens
                configuration.deleteRealmIfMigrationNeeded = true
                //////
                Realm.Configuration.defaultConfiguration = configuration
                _ = try Realm()
                let folderPath = fileURL.path
                log.debug("REALM DB:\(folderPath)")
            } catch let error {
                log.severe(error)
                log.severe("Unable to open Realm DB")
                exit(0)
            }
        }
    }

    var lastUpdate: Date? {
        get {
            let timeInterval = UserDefaults().double(forKey: kLastUpdate)
            return Date(timeIntervalSince1970: timeInterval)
        }

        set (newLastUpdate) {
            if let newLastUpdate = newLastUpdate {
                let timeInterval = newLastUpdate.timeIntervalSince1970
                UserDefaults().set(timeInterval, forKey: kLastUpdate)
            }
        }
    }

    func startSync(offset: TimeInterval?, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        self.nextIndexDatasource.updateOffsetIfNeeded(offset: offset)

        log.info("start sync")
        try? self.synchronize { (success) in
            if success {
                log.info("sync succeded")
            } else {
                log.error("sync error")
            }
            if success {
                completionHandler(UIBackgroundFetchResult.newData)
            } else {
                completionHandler(UIBackgroundFetchResult.noData)
            }
        }
    }
}
