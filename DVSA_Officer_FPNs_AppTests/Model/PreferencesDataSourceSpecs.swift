//
//  PreferencesDataSourceSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
import AWSAuthCore
@testable import DVSA_Officer_FPNs_App

class AWSSignInProviderMock: NSObject, AWSSignInProvider {

    var isLoggedIn: Bool = true
    var done = TestDone()

    func login(_ completionHandler: @escaping (Any?, Error?) -> Void) {
        done["login"] = true
        completionHandler(nil, nil)
    }

    func logout() {
        done["logout"] = true
    }

    func reloadSession() {
        done["reloadSession"] = true
    }

    var identityProviderName: String = ""

    func token() -> AWSTask<NSString> {
        done["token"] = true
        return AWSTask(result: "token")
    }

}

class AWSIdentityManagerMock: NSObject, AWSIdentityManagerProtocolHelper {

    var identityId: String?

    func logins() -> AWSTask<NSDictionary> {
        return AWSTask(result: [:])
    }
}

class PreferencesDataSourceSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("PreferencesDataSource") {

            let realmTempFileName = "PreferencesDataSource.realm"
            var preferences: PreferencesDataSource!
            var site: SiteObject!
            var realm: Realm?

            var nextIndexDataSourceMock: NextIndexDatasourceMock!
            var snsManagerMock: AWSSNSManagerMock!
            var signInProviderMock: AWSSignInProviderMock!
            var identityManagerMock: AWSIdentityManagerMock!

            beforeEach {

                nextIndexDataSourceMock = NextIndexDatasourceMock()
                signInProviderMock = AWSSignInProviderMock()
                snsManagerMock = AWSSNSManagerMock()
                identityManagerMock = AWSIdentityManagerMock()

                preferences = PreferencesDataSource.shared
                preferences.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                preferences.signInProvider = signInProviderMock
                preferences.nextIndexDataSource = nextIndexDataSourceMock
                preferences.snsManager = snsManagerMock
                preferences.identityManager = identityManagerMock

                PreferencesDataSource.shared.username = nil
                PreferencesDataSource.shared.userID = nil

                let configuration = RealmUtils.setupTest(name: realmTempFileName)!
                realm = try? Realm(configuration: configuration)
                site = SiteObject()
                site?.code = 300
                site?.name = "London"
                site?.region = "West England"
            }

            afterEach {
                RealmUtils.removeTest(name: realmTempFileName)
            }

            context("username") {

                it("should set keychain") {
                    let preferences = PreferencesDataSource()
                    expect(preferences.username).to(beNil())
                    preferences.username = "test.3"
                    expect(preferences.username).to(equal("test.3"))

                    let kUserName = "kPreferencesDataSourceUserName"
                    let keychain = AWSUICKeyChainStore(service: Bundle.main.bundleIdentifier!)
                    let username = keychain.string(forKey: kUserName)
                    expect(username).to(equal("test.3"))

                    preferences.username = nil
                    expect(preferences.username).to(beNil())
                    let username2 = keychain.string(forKey: kUserName)
                    expect(username2).to(beNil())
                }
            }

            context("userID") {

                it("should set keychain") {
                    let preferences = PreferencesDataSource()
                    expect(preferences.username).to(beNil())
                    preferences.userID = "test.user-id"
                    expect(preferences.userID).to(equal("test.user-id"))

                    let kUserID = "kPreferencesDataSourceUserID"
                    let keychain = AWSUICKeyChainStore(service: Bundle.main.bundleIdentifier!)
                    let userID = keychain.string(forKey: kUserID)
                    expect(userID).to(equal("test.user-id"))

                    preferences.userID = nil
                    expect(preferences.userID).to(beNil())
                    let userID2 = keychain.string(forKey: kUserID)
                    expect(userID2).to(beNil())
                }
            }

            context("userPreferences") {
                it("should return a UserPreference") {

                    let preferences = PreferencesDataSource()
                    preferences.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    var userPreferences = preferences.userPreferences()
                    expect(userPreferences?.username).to(beNil())
                    expect(userPreferences?.siteLocation).to(beNil())
                    preferences.username = "test.user"
                    userPreferences = preferences.userPreferences()
                    expect(userPreferences).toNot(beNil())
                    expect(userPreferences?.username).to(equal("test.user"))
                }
            }

            context("shared") {
                it("should be a singleton") {

                    preferences.username = "test.user"
                    var userPreferences = preferences.userPreferences()

                    let singleton = PreferencesDataSource.shared
                    singleton.configuration = RealmUtils.setupTest(name: realmTempFileName)!

                    singleton.username = "test.user"
                    var singletonPreferences = singleton.userPreferences()

                    expect(userPreferences).toNot(beNil())
                    expect(singletonPreferences).toNot(beNil())
                    expect(userPreferences?.username).to(equal(singletonPreferences?.username))

                    singleton.username = "test.user2"
                    singletonPreferences = singleton.userPreferences()
                    userPreferences = preferences.userPreferences()
                    expect(userPreferences).toNot(beNil())
                    expect(singletonPreferences).toNot(beNil())
                    expect(userPreferences?.username).to(equal(singletonPreferences?.username))
                }
            }

            context("updateSite") {
                it("should save the site") {

                    let preferences = PreferencesDataSource()
                    preferences.configuration = RealmUtils.setupTest(name: realmTempFileName)!

                    preferences.username = nil
                    var result = preferences.updateSite(site: site)
                    expect(result).to(beFalse())

                    preferences.username = "test.user"
                    result = preferences.updateSite(site: site)
                    expect(result).to(beTrue())

                    let userPreferences = preferences.userPreferences()

                    expect(userPreferences?.username).to(equal("test.user"))
                    expect(userPreferences?.siteLocation?.name).to(equal("London"))
                    expect(userPreferences?.siteLocation?.region).to(equal("West England"))
                    expect(userPreferences?.siteLocation?.code).to(equal(300))

                    expect(userPreferences?.isMobile).to(beFalse())

                    let site = preferences.site()

                    expect(site?.name).to(equal("London"))
                    expect(site?.region).to(equal("West England"))
                    expect(site?.code).to(equal(300))
                }
            }

            context("updateMobileSite") {
                it("should save the site") {

                    let preferences = PreferencesDataSource()
                    preferences.configuration = RealmUtils.setupTest(name: realmTempFileName)!

                    preferences.username = nil

                    let site = SiteObject()
                    site.code = -1
                    site.name = "Area 1"
                    site.region = SiteRegion.mobile.rawValue

                    var result = preferences.updateMobileSite(site: site, mobileAddress: "My Address")
                    expect(result).to(beFalse())

                    preferences.username = "test.user"
                    result = preferences.updateMobileSite(site: site, mobileAddress: "My Address")
                    expect(result).to(beTrue())

                    let userPreferences = preferences.userPreferences()

                    expect(userPreferences?.username).to(equal("test.user"))
                    expect(userPreferences?.mobileLocation?.name).to(equal("Area 1"))
                    expect(userPreferences?.mobileLocation?.region).to(equal("Mobile"))
                    expect(userPreferences?.mobileLocation?.code).to(equal(-1))

                    expect(userPreferences?.isMobile).to(beTrue())

                    let site1 = preferences.site()

                    expect(site1?.name).to(equal("Area 1"))
                    expect(site1?.region).to(equal("Mobile"))
                    expect(site1?.code).to(equal(-1))
                }
            }

            context("getSite") {
                it("should get a site by code") {

                    try? realm?.write {
                        realm?.add(site, update: true)
                    }

                    let site = preferences.getSite(code: 300)
                    expect(site?.name).to(equal("London"))
                    expect(site?.region).to(equal("West England"))
                    expect(site?.code).to(equal(300))

                }
            }

            context("clean") {
                it("should clean realm") {

                    preferences.username = "test.user3"
                    preferences.userID = "test.user.id"

                    let record = realm?.object(ofType: UserPreferences.self, forPrimaryKey: "test.user3")
                    expect(record).toNot(beNil())

                    let result = preferences.clean()
                    expect(preferences.username).to(beNil())
                    expect(preferences.userID).to(beNil())
                    expect(preferences.site()).to(beNil())
                    expect(preferences.userPreferences()).to(beNil())

                    expect(result).to(beTrue())
                    let record2 = realm?.object(ofType: UserPreferences.self, forPrimaryKey: "test.user3")
                    expect(record2).to(beNil())
                }
            }

            context("subscribeUserPreferences") {
                it("should call reset") {

                    preferences.subscribeUserPreferences(isFirstLogin: true)
                    expect(nextIndexDataSourceMock.done["reset"]).to(beTrue())
                }

                it ("should subscribe") {
                    identityManagerMock.identityId = "myid"
                    preferences.subscribeUserPreferences(isFirstLogin: true)
                    expect(signInProviderMock.done["token"]).to(beTrue())
                    expect(snsManagerMock.done["registerToken"]).to(beTrue())
                }

                it ("should not subscribe") {
                    identityManagerMock.identityId = nil
                    preferences.subscribeUserPreferences(isFirstLogin: true)
                    expect(nextIndexDataSourceMock.done["reset"]).to(beTrue())
                    expect(signInProviderMock.done["token"]).to(beFalse())
                    expect(snsManagerMock.done["registerToken"]).to(beFalse())
                }

                it("should not call reset") {
                    preferences.subscribeUserPreferences(isFirstLogin: false)
                    expect(nextIndexDataSourceMock.done["reset"]).to(beFalse())
                }
            }

            context("unsubscribeUserPreferences") {
                it("should call unsubscribeUserPreferences") {

                    preferences.unsubscribeUserPreferences {

                    }
                    expect(snsManagerMock.done["unsubscribeUserPreferences"]).to(beFalse())
                }
            }
        }
    }
}
