//
//  PersistentDataSourceSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 05/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
@testable import DVSA_Officer_FPNs_App

import Foundation

class PersistentDataSourceSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("PersistentDataSource_observe") {
            context("BodyObject") {

                let realmTempFileName = "PersistentDataSourceSpecs_observe_BodyObjectQueue.realm"
                var datasource: PersistentDataSource!

                afterEach {
                    RealmUtils.removeTest(name: realmTempFileName)
                }

                it("should observe changes") {

                    datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!

                    let queue = DispatchQueue(label: "BodyObjectQueue")
                    queue.async {
                        let realm = try? Realm(configuration: datasource.configuration)
                        let body = BodyObject.randomBody()!
                        try? realm?.write {

                            realm?.add(body, update: true)
                        }
                        _ = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    }

                    let expectation0 = self.expectation(description: "Notification Body fired")

                    let notification = datasource.observe { results in
                        guard let count = results?.count else {
                            return
                        }
                        if count > 0 {
                            expectation0.fulfill()
                        }
                    }
                    self.wait(for: [expectation0], timeout: 10.0)
                    notification?.invalidate()
                }
            }

            context("SiteObject") {

                let realmTempFileName = "PersistentDataSourceSpecs_observe_SiteObjectQueue.realm"
                var datasource: PersistentDataSource!

                afterEach {
                    RealmUtils.removeTest(name: realmTempFileName)
                }

                it("should observe changes") {

                    datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!

                    let queue = DispatchQueue(label: "SiteObjectQueue")
                    queue.async {
                        let realm = try? Realm(configuration: datasource.configuration)

                        let site1 = SiteObject()
                        site1.name = "Site 1"
                        site1.code = 1
                        site1.region = "West England"
                        try? realm?.write {
                            realm?.add(site1, update: true)
                        }
                    }

                    let expectation0 = self.expectation(description: "Notification Site fired 1")

                    let notification = datasource.observeSites { results in

                        guard let count = results?.count else {
                            return
                        }
                        if count > 0 {
                            expectation0.fulfill()
                        }
                    }

                    self.wait(for: [expectation0], timeout: 10.0)
                    notification?.invalidate()
                }
            }
        }

        describe("PersistentBodyDataSource") {

            let realmTempFileName = "PersistentDataSourceSpecs.realm"
            var sites: [SiteObject]!
            var realm: Realm?

            afterEach {
                RealmUtils.removeTest(name: realmTempFileName)
            }

            context("list") {

                it("should return saved objects sorted by offset") {

                    let datasource = PersistentDataSource()
                    let realmTempFileName = "PersistentDataSourceSpecs_list.realm"
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        for _ in 0..<10 {
                            if let body = BodyObject.randomBody() {
                                realm?.add(body, update: true)
                            }
                        }
                    }
                    let objects = datasource.list()
                    expect(objects).toNot(beNil())
                    expect(objects?.count).to(equal(10))
                    for value in 1..<(objects?.count ?? 2) {
                        expect(objects?[value - 1].offset).to(beGreaterThan(objects?[value].offset))
                    }
                    RealmUtils.removeTest(name: realmTempFileName)
                }
            }

            context("sites") {

                it("should return saved objects sorted by name") {

                    let site1 = SiteObject()
                    site1.name = "Site 1"
                    site1.code = 1
                    site1.region = "West England"

                    let site2 = SiteObject()
                    site2.name = "Site 2"
                    site2.code = 2
                    site2.region = "East England"

                    sites = [site1, site2]

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        for site in sites {
                            realm?.add(site, update: true)
                        }
                    }

                    let objects = datasource.sites()
                    expect(objects).toNot(beNil())
                    expect(objects?.count).to(equal(2))
                    for ival in 1..<(objects?.count ?? 2) {
                        expect(objects?[ival - 1].name).to(beLessThan(objects?[ival].name))
                    }
                }
            }

            context("item") {

                it("should return saved item") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    realm = try? Realm(configuration: datasource.configuration)

                    let body = BodyObject.randomBody()!
                    let key = body.key
                    let realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        realm?.add(body, update: true)
                    }

                    let result = datasource.item(for: key)
                    expect(result).toNot(beNil())
                    expect(result).to(equal(body))
                }
            }

            context("item") {

                it("should return saved item") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    realm = try? Realm(configuration: datasource.configuration)

                    let body = BodyObject.randomBody()!
                    let key = body.key
                    let realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        realm?.add(body, update: true)
                    }

                    let result = datasource.item(for: key)
                    expect(result).toNot(beNil())
                    expect(result).to(equal(body))
                }
            }

            context("insert") {

                it("should insert item") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    realm = try? Realm(configuration: datasource.configuration)

                    let body = BodyObject.randomBody()!
                    try? datasource.insert(item: body)

                    let realm = try? Realm(configuration: datasource.configuration)
                    let result = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    expect(result).toNot(beNil())
                    expect(result).to(equal(body))
                    expect(result?.status).to(equal(SynchStatusType.pending.rawValue))
                }

                it("should update item if disabled") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    realm = try? Realm(configuration: datasource.configuration)

                    let body = BodyObject.randomBody()!
                    body.enabled = false
                    try? datasource.insert(item: body)

                    let result = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    expect(result).toNot(beNil())
                    expect(result).to(equal(body))
                    expect(result?.enabled).to(beFalse())
                    expect(result?.status).to(equal(SynchStatusType.pending.rawValue))

                    let body2 = BodyObject()
                    body2.key = body.key
                    body2.enabled = true
                    body2.hashToken = "New"
                    let offset = body.offset + 10
                    body2.offset = offset
                    body2.value = body.value

                    try? datasource.insert(item: body2)
                    let result2 = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    expect(result2).toNot(beNil())
                    expect(result2).to(equal(body))
                    expect(result2?.enabled).to(beTrue())
                    expect(result2?.offset).to(equal(offset))
                    expect(result2?.hashToken).to(equal(body.hashToken))
                    expect(result2?.status).to(equal(SynchStatusType.pending.rawValue))
                }

                it("should not update item if enabled") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    realm = try? Realm(configuration: datasource.configuration)

                    let body = BodyObject.randomBody()!
                    try? datasource.insert(item: body)

                    let result = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    expect(result).toNot(beNil())
                    expect(result).to(equal(body))
                    expect(result?.enabled).to(beTrue())
                    expect(result?.status).to(equal(SynchStatusType.pending.rawValue))

                    let body2 = BodyObject()
                    body2.key = body.key
                    body2.enabled = true
                    body2.hashToken = body.hashToken
                    body2.offset = body.offset + 10
                    body2.value = body.value

                    try? datasource.insert(item: body2)
                    let result2 = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    expect(result2).toNot(beNil())
                    expect(result2).to(equal(body))
                    expect(result2?.enabled).to(beTrue())
                    expect(result2?.offset).to(equal(body.offset))
                    expect(result2?.status).to(equal(SynchStatusType.pending.rawValue))
                }
            }

            context("update") {

                it("should update item") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    let body = BodyObject.randomBody()!
                    let realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        realm?.add(body, update: true)
                    }

                    let body2 = BodyObject.randomBody()!
                    body2.key = body.key
                    try? datasource.update(item: body)
                    let result = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    expect(result).toNot(beNil())
                    expect(result).toNot(equal(body2))
                    expect(result?.status).to(equal(SynchStatusType.pending.rawValue))
                }
            }

            context("delete") {

                it("should delete item") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    let body = BodyObject.randomBody()!
                    let realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        realm?.add(body, update: true)
                    }

                    try? datasource.delete(item: body)
                    let result = realm?.object(ofType: BodyObject.self, forPrimaryKey: body.key)
                    expect(result).toNot(beNil())
                    expect(result?.enabled).to(beFalse())
                    expect(result?.status).to(equal(SynchStatusType.pending.rawValue))
                }
            }

            context("clean") {

                it("should update item") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    let body = BodyObject.randomBody()!
                    let key = body.key
                    let realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        realm?.add(body, update: true)
                    }

                    let document = body.value
                    let vehicleDetails = body.value?.vehicleDetails
                    let trailerDetails = body.value?.trailerDetails
                    let driverDetails = body.value?.driverDetails

                    try? datasource.clean()
                    expect(body.isInvalidated).to(beTrue())
                    expect(document?.isInvalidated).to(beTrue())
                    expect(vehicleDetails?.isInvalidated).to(beTrue())
                    expect(trailerDetails?.isInvalidated).to(beTrue())
                    expect(driverDetails?.isInvalidated).to(beTrue())
                    let result = realm?.object(ofType: BodyObject.self, forPrimaryKey: key)
                    expect(result).to(beNil())
                }
            }

            context("removeExpiredDocuments") {

                it("should update item") {

                    let datasource = PersistentDataSource()
                    datasource.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                    let body = BodyObject.randomBody()!
                    let body2 = BodyObject.randomBody()!
                    body.offset = Date.todayUTC.addingTimeInterval(-2*60)
                    body2.offset = Date()
                    let key = body.key
                    let key2 = body2.key
                    let realm = try? Realm(configuration: datasource.configuration)
                    try? realm?.write {
                        realm?.add(body, update: true)
                        realm?.add(body2, update: true)
                    }

                    let document = body.value
                    let vehicleDetails = body.value?.vehicleDetails
                    let trailerDetails = body.value?.trailerDetails
                    let driverDetails = body.value?.driverDetails

                    let document2 = body2.value
                    let vehicleDetails2 = body2.value?.vehicleDetails
                    let trailerDetails2 = body2.value?.trailerDetails
                    let driverDetails2 = body2.value?.driverDetails

                    try? datasource.removeExpiredDocuments(offset: 60)

                    expect(body.isInvalidated).to(beTrue())
                    expect(document?.isInvalidated).to(beTrue())
                    expect(vehicleDetails?.isInvalidated).to(beTrue())
                    expect(trailerDetails?.isInvalidated).to(beTrue())
                    expect(driverDetails?.isInvalidated).to(beTrue())

                    expect(body2.isInvalidated).to(beFalse())
                    expect(document2?.isInvalidated).to(beFalse())
                    expect(vehicleDetails2?.isInvalidated).to(beFalse())
                    expect(trailerDetails2?.isInvalidated).to(beFalse())
                    expect(driverDetails2?.isInvalidated).to(beFalse())

                    let result = realm?.object(ofType: BodyObject.self, forPrimaryKey: key)
                    expect(result).to(beNil())

                    let result2 = realm?.object(ofType: BodyObject.self, forPrimaryKey: key2)
                    expect(result2).toNot(beNil())
                }
            }

        }
    }
}
