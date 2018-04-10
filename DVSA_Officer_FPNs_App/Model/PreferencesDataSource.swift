//
//  PreferencesDatasource.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift
import AWSAuthUI
import JWTDecode

protocol PreferencesDataSourceProtocol {
    var username: String? { get set }
    var userID: String? { get set }
    func userPreferences() -> UserPreferences?
    func updateSite(site: SiteObject) -> Bool
    func updateMobileSite(site: SiteObject, mobileAddress: String) -> Bool
    func site() -> SiteObject?
    func getSite(code: Int) -> SiteObject?
    func observePreferenceChange(completion: @escaping (UserPreferences?) -> Void) -> NotificationToken?
    func subscribeUserPreferences(isFirstLogin: Bool)
    func unsubscribeUserPreferences(completion: @escaping () -> Void)
    func clean() -> Bool
}

@objc protocol AWSIdentityManagerProtocolHelper: class, AWSIdentityProviderManager {
    @objc var identityId: String? { get }
}

extension AWSIdentityManager: AWSIdentityManagerProtocolHelper {

}

class PreferencesDataSource: PreferencesDataSourceProtocol {

    static let shared = PreferencesDataSource()

    var configuration = Realm.Configuration.defaultConfiguration
    var notificationToken: NotificationToken?

    var nextIndexDataSource: NextIndexDatasource = LocalNextIndexDatasource()
    var snsManager: AWSSNSManagerDelegate = AWSSNSManager.shared
    var signInProvider: AWSSignInProvider =  AWSADALSignInProvider.sharedInstance()
    var identityManager: AWSIdentityManagerProtocolHelper = AWSIdentityManager.default()

    internal let keychain: AWSUICKeyChainStore
    internal let kUserName = "kPreferencesDataSourceUserName"
    internal let kUserID = "kPreferencesDataSourceUserID"

    init() {
        self.keychain = AWSUICKeyChainStore(service: Bundle.main.bundleIdentifier!)
    }

    var userID: String? {
        get {
            return self.keychain.string(forKey: kUserID)
        }

        set (newUserID) {
            if let newUserID = newUserID {
                self.keychain.setString(newUserID, forKey: kUserID)
            } else {
                self.keychain.removeItem(forKey: kUserID)
            }
            _ = userPreferences()
        }
    }

    var username: String? {
        get {
            return self.keychain.string(forKey: kUserName)
        }

        set (newUsername) {
            if let newUsername = newUsername {
                self.keychain.setString(newUsername, forKey: kUserName)
            } else {
                self.keychain.removeItem(forKey: kUserName)
            }
            _ = userPreferences()
        }
    }

    func site() -> SiteObject? {
        guard let userPreferences = self.userPreferences() else {
            return nil
        }
        return userPreferences.isMobile ? userPreferences.mobileLocation : userPreferences.siteLocation
    }

    func getSite(code: Int) -> SiteObject? {
        do {
            let realm = try Realm(configuration: self.configuration)
            return realm.object(ofType: SiteObject.self, forPrimaryKey: code)
        } catch {
            return nil
        }
    }

    func userPreferences() -> UserPreferences? {

        guard let username = self.username else {
            return nil
        }
        do {
            let realm = try Realm(configuration: self.configuration)
            guard let userPreferences = realm.object(ofType: UserPreferences.self, forPrimaryKey: username) else {
                let userPreferences = UserPreferences()
                userPreferences.username = username
                try realm.write {
                    realm.add(userPreferences, update: true)
                }
                return userPreferences
            }
            return userPreferences
        } catch {
            return nil
        }
    }

    func updateSite(site: SiteObject) -> Bool {
        guard let username = self.username,
            username != "" else {
            return false
        }

        do {
            let realm = try Realm(configuration: self.configuration)
            guard let userPreferences = realm.object(ofType: UserPreferences.self, forPrimaryKey: username) else {
                return false
            }
            try realm.write {
                realm.add(site, update: true)
                if site.code > 0 {
                    userPreferences.siteLocation = site
                    userPreferences.isMobile = false
                    realm.add(userPreferences, update: true)
                }
            }
            return true
        } catch {
            return false
        }
    }

    func updateMobileSite(site: SiteObject, mobileAddress: String) -> Bool {
        guard let username = self.username,
            username != "" else {
                return false
        }

        do {
            let realm = try Realm(configuration: self.configuration)
            guard let userPreferences = realm.object(ofType: UserPreferences.self, forPrimaryKey: username) else {
                return false
            }
            try realm.write {
                realm.add(site, update: true)
                if site.code < 0 {
                    userPreferences.mobileLocation = site
                    userPreferences.mobileAddress = mobileAddress
                    userPreferences.isMobile = true
                    realm.add(userPreferences, update: true)
                }
            }
            return true
        } catch {
            return false
        }
    }

    func clean() -> Bool {
        do {
            let realm = try Realm(configuration: self.configuration)
            let objectsToDelete = realm.objects(UserPreferences.self)
            try realm.write {
                realm.delete(objectsToDelete)
            }
            self.username = nil
            self.userID = nil
        } catch {
            return false
        }
        return true
    }

    func observePreferenceChange(completion: @escaping (UserPreferences?) -> Void) -> NotificationToken? {
        let realm = try? Realm(configuration: self.configuration)
        if let username = self.username,
            username != "" {
            let userPreferences = realm?.object(ofType: UserPreferences.self, forPrimaryKey: username)
            return userPreferences?.observe { (change) in
                switch change {
                case .error:
                    completion(nil)
                case .change:
                    completion(userPreferences)
                case .deleted:
                    completion(nil)
                }
            }
        }
        return nil
    }

    func subscribeUserPreferences(isFirstLogin: Bool) {

        if isFirstLogin {
            self.nextIndexDataSource.reset()
        }
        if let identityId = identityManager.identityId {
            log.debug("Cognito Identity: \(identityId)")
            signInProvider.token().continueWith { [weak self] (task) -> Void in
                guard task.error == nil else {
                    log.error("Missing the officer ID")
                    return
                }

                if let token = task.result as String?,
                    let jwt = try? decode(jwt: token) {
                    self?.username = jwt.body["unique_name"] as? String
                    self?.userID = jwt.subject
                }
            }
            self.snsManager.registerToken(user: identityId)
        } else {
            log.severe("Unable to update user preferences")
        }
    }

    func unsubscribeUserPreferences(completion: @escaping () -> Void) {
        self.snsManager.unsubscribe { _ in
           completion()
        }
    }
}
