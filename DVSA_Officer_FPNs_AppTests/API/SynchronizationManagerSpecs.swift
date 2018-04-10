//
//  SynchronizationManagerSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 20/12/2017.
//Copyright © 2017 Andrea Scuderi. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
import Realm
@testable import DVSA_Officer_FPNs_App

class SynchronizationManagerSpecs: QuickSpec {

    func deleteOneObject(synchManager: SynchronizationManager) -> AWSBodyModel {
        let model = DataMock.shared.bodyModelToUpdate!
        let bodyToUpdate = BodyObject(model: model)!
        model.enabled = false
        bodyToUpdate.status = SynchStatusType.pending.rawValue

        let realm = try? Realm(configuration: synchManager.configuration)
        try? realm?.write {
            realm?.add(bodyToUpdate, update: true)
        }
        let objectsCount = realm?.objects(BodyObject.self).count
        expect(objectsCount).to(be(1))
        return model
    }

    func updateOneObject(synchManager: SynchronizationManager) -> AWSBodyModel {

        let model = DataMock.shared.bodyModelToUpdate!
        var bodyToUpdate: BodyObject!
        model.value?.driverDetails?.name = "James Moriarty 42"
        model.value?.penaltyAmount = NSNumber(value: UInt16(63))
        bodyToUpdate = BodyObject(model: model)!
        bodyToUpdate.status = SynchStatusType.pending.rawValue
        let realm = try? Realm(configuration: synchManager.configuration)
        try? realm?.write {
            realm?.add(bodyToUpdate)
        }
        let objectsCount = realm?.objects(BodyObject.self).count
        expect(objectsCount).to(be(1))
        return model
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        let realmTempFileName = "SynchronizationManager.realm"

        describe("SynchronizationManager") {

            var datamanager: APIDataManagerMock!
            var synchManager: SynchronizationManager!
            var nextIndedDatasource: NextIndexDatasourceMock!

            beforeEach {
                datamanager = APIDataManagerMock()
                datamanager.isResponseNotNil = true
                nextIndedDatasource = NextIndexDatasourceMock()
                synchManager = SynchronizationManager()
                synchManager.configuration = RealmUtils.setupTest(name: realmTempFileName)!
                synchManager.datamanager = datamanager
                synchManager.nextIndexDatasource = nextIndedDatasource
            }

            afterEach {
                RealmUtils.removeTest(name: realmTempFileName)
            }

            context("getKey") {
                let key = SynchronizationManager.getKey()
                expect(key).toNot(beNil())
            }

            context("setup") {
                SynchronizationManager.setup()
                let defaultSynchManager = SynchronizationManager()
                let path = defaultSynchManager.configuration.fileURL!.path
                let fileExists  = FileManager.default.fileExists(atPath: path)
                expect(fileExists).to(beTrue())
            }

            context("delete") {

                it("should call datamanager delete") {
                    synchManager.delete(item: DataMock.shared.bodyModel!) { _ in

                    }
                    expect(datamanager.done["delete"]).toEventually(beTrue())
                }

                it("should update item.enabled with a valid token") {

                    let model = self.deleteOneObject(synchManager: synchManager)

                    let realm = try? Realm(configuration: synchManager.configuration)
                    synchManager.delete(item: model) { _ in

                    }
                    let objectsCount = realm?.objects(BodyObject.self).count
                    expect(objectsCount).to(be(1))

                    let object = realm?.objects(BodyObject.self).first
                    expect(object?.key).to(equal(model.key))
                    expect(object?.enabled).to(beFalse())
                    expect(object?.hashToken).toNot(equal(model.hashToken))
                    expect(object?.status).to(equal(SynchStatusType.updated.rawValue))

                }

                context("when response fails") {

                    it("should leave the data unchanged") {
                        datamanager.isResponseNotNil = false
                        synchManager.datamanager = datamanager

                        let model = self.deleteOneObject(synchManager: synchManager)

                        let realm = try? Realm(configuration: synchManager.configuration)
                        synchManager.delete(item: model) { _ in

                        }
                        let objectsCount = realm?.objects(BodyObject.self).count
                        expect(objectsCount).to(be(1))

                        let object = realm?.objects(BodyObject.self).first
                        expect(object?.key).to(equal(model.key))
                        expect(object?.enabled).to(beFalse())

                        expect(object?.hashToken).to(equal(model.hashToken))
                        expect(object?.status).to(equal(SynchStatusType.pending.rawValue))
                    }
                }
            }

            context("download") {
                it("should download and store items") {
                    let realm = try? Realm(configuration: synchManager.configuration)
                    let objects = realm?.objects(BodyObject.self).count
                    expect(objects).to(be(0))
                    expect(datamanager.bodyListModel?.items?.count).to(equal(102))
                    synchManager.download(completion: { (value) in
                        expect(value).to(beTrue())
                        return
                    })
                    expect(datamanager.done["list"]).toEventually(beTrue())
                    let objectsAfterSync = realm?.objects(BodyObject.self).count
                    expect(objectsAfterSync).to(be(96))
                }

                context("when response fails") {

                    it("should leave the data unchanged") {
                        datamanager.isResponseNotNil = false
                        synchManager.datamanager = datamanager

                        let realm = try? Realm(configuration: synchManager.configuration)
                        let objects = realm?.objects(BodyObject.self).count
                        expect(objects).to(be(0))
                        expect(datamanager.bodyListModel?.items?.count).to(equal(102))
                        synchManager.download { (value) in
                            expect(value).to(beFalse())
                            return
                        }
                        expect(datamanager.done["list"]).toEventually(beTrue())
                        let objectsAfterSync = realm?.objects(BodyObject.self).count
                        expect(objectsAfterSync).to(be(0))
                    }
                }
            }

            context("uploadPending") {

                beforeEach {

                }

                it("should update items") {

                    let realm = try? Realm(configuration: synchManager.configuration)
                    synchManager.download { (value) in
                        expect(value).to(beTrue())
                        return
                    }
                    let objectsAfterSync = realm?.objects(BodyObject.self).count
                    expect(objectsAfterSync).to(be(96))

                    let addedBodyModel = DataMock.shared.addedBodyModel!
                    let conflictedBodyModel = DataMock.shared.conflictedBodyModel!
                    let bodyModelUpdated = DataMock.shared.bodyModelUpdated!

                    let items = [addedBodyModel, conflictedBodyModel, bodyModelUpdated]
                    try? realm?.write {
                        let obj1 = BodyObject(model: addedBodyModel)!
                        obj1.status = SynchStatusType.pending.rawValue
                        realm?.add(obj1, update: false)
                    }

                    synchManager.uploadPending(items: items) { (value) in
                        expect(value).to(beTrue())
                        return
                    }

                    let obj1 = realm?.object(ofType: BodyObject.self, forPrimaryKey: addedBodyModel.key!)
                    expect(obj1?.status).to(equal(SynchStatusType.updated.rawValue))

                    let obj2 = realm?.object(ofType: BodyObject.self, forPrimaryKey: bodyModelUpdated.key!)
                    expect(obj2?.status).to(equal(SynchStatusType.updated.rawValue))

                    let obj3 = realm?.object(ofType: BodyObject.self, forPrimaryKey: conflictedBodyModel.key!)
                    expect(obj3?.status).to(equal(SynchStatusType.conflicted.rawValue))
                }

                context("when response fails ") {

                    it("should leave the data unchanged") {

                        datamanager.isResponseNotNil = false
                        synchManager.datamanager = datamanager

                        let addedBodyModel = DataMock.shared.addedBodyModel!
                        let conflictedBodyModel = DataMock.shared.conflictedBodyModel!
                        let bodyModelUpdated = DataMock.shared.bodyModelUpdated!

                        let items = [addedBodyModel, conflictedBodyModel, bodyModelUpdated]
                        let realm = try? Realm(configuration: synchManager.configuration)
                        try? realm?.write {
                            let obj1 = BodyObject(model: addedBodyModel)!
                            obj1.status = SynchStatusType.pending.rawValue
                            realm?.add(obj1, update: false)
                        }

                        synchManager.uploadPending(items: items) { (value) in
                            expect(value).to(beFalse())
                            return
                        }

                        let obj1 = realm?.object(ofType: BodyObject.self, forPrimaryKey: addedBodyModel.key!)
                        expect(obj1?.status).to(equal(SynchStatusType.pending.rawValue))
                    }
                }

            }

            context("startSync") {
                it("should call updateOffsetIfNeeded and synchronize") {
                    let realm = try? Realm(configuration: synchManager.configuration)
                    let objects = realm?.objects(BodyObject.self).count
                    expect(objects).to(be(0))
                    expect(datamanager.bodyListModel?.items?.count).to(equal(102))
                    let expectation1 = self.expectation(description: "performFetchWithCompletionHandler")

                    synchManager.startSync(offset: nil, performFetchWithCompletionHandler: { (result) in

                        expect(result).to(equal(UIBackgroundFetchResult.newData))
                        expectation1.fulfill()
                    })

                    self.waitForExpectations(timeout: 5.0, handler: nil)

                    expect(nextIndedDatasource.done["updateOffsetIfNeeded"]).toEventually(beTrue())
                    expect(datamanager.done["list"]).toEventually(beTrue())

                }
            }

            context("reachabilityDidChange") {

                context("when no pending") {
                    it("isReachable should return false") {

                        let realm = try? Realm(configuration: synchManager.configuration)
                        let objects = realm?.objects(BodyObject.self).count
                        expect(objects).to(be(0))
                        expect(datamanager.bodyListModel?.items?.count).to(equal(102))
                        let isSyncRequired = synchManager.isSyncRequired()
                        expect(isSyncRequired).toEventually(beFalse())
                        synchManager.reachabilityDidChange(isReachable: true)
                        expect(datamanager.done["list"]).toEventually(beFalse())
                    }

                    it("not isReachable should return false") {
                        let realm = try? Realm(configuration: synchManager.configuration)
                        let objects = realm?.objects(BodyObject.self).count
                        expect(objects).to(be(0))
                        expect(datamanager.bodyListModel?.items?.count).to(equal(102))
                        let isSyncRequired = synchManager.isSyncRequired()
                        expect(isSyncRequired).toEventually(beFalse())
                        synchManager.reachabilityDidChange(isReachable: false)
                        expect(datamanager.done["list"]).toEventually(beFalse())
                    }
                }

                context("when pending") {

                    beforeEach {
                        let realm = try? Realm(configuration: synchManager.configuration)
                        synchManager.download { (value) in
                            expect(value).to(beTrue())
                            return
                        }
                        let objectsAfterSync = realm?.objects(BodyObject.self).count
                        expect(objectsAfterSync).to(be(96))
                    }

                    it("isReachable should return true") {

                        let realm = try? Realm(configuration: synchManager.configuration)
                        try? realm?.write {
                            let addedBody = realm?.objects(BodyObject.self).filter("key == '24010910'").first
                            addedBody?.status = SynchStatusType.pending.rawValue
                        }
                        let isSyncRequired = synchManager.isSyncRequired()
                        expect(isSyncRequired).toEventually(beTrue())

                        synchManager.reachabilityDidChange(isReachable: true)
                        expect(datamanager.done["update"]).toEventually(beTrue())
                    }

                    it("not isReachable should return false") {

                        let realm = try? Realm(configuration: synchManager.configuration)
                        try? realm?.write {
                            let addedBody = realm?.objects(BodyObject.self).filter("key == '24010910'").first
                            addedBody?.status = SynchStatusType.pending.rawValue
                        }
                        let isSyncRequired = synchManager.isSyncRequired()
                        expect(isSyncRequired).toEventually(beTrue())

                        synchManager.reachabilityDidChange(isReachable: false)
                        expect(datamanager.done["update"]).toEventually(beFalse())
                    }
                }
            }

            context("synchronize") {

                context("when no pending") {
                    it("should call list") {

                        let realm = try? Realm(configuration: synchManager.configuration)
                        let objects = realm?.objects(BodyObject.self).count
                        expect(objects).to(be(0))
                        expect(datamanager.bodyListModel?.items?.count).to(equal(102))
                        try? synchManager.synchronize(completion: { (value) in
                            expect(value).to(beTrue())
                            return
                        })
                        expect(datamanager.done["list"]).toEventually(beTrue())
                    }
                }

                context("when pending") {

                    beforeEach {
                        let realm = try? Realm(configuration: synchManager.configuration)
                        synchManager.download { (value) in
                            expect(value).to(beTrue())
                            return
                        }
                        let objectsAfterSync = realm?.objects(BodyObject.self).count
                        expect(objectsAfterSync).to(be(96))
                    }

                    it("should call update and list") {

                        let realm = try? Realm(configuration: synchManager.configuration)
                        try? realm?.write {
                            let addedBody = realm?.objects(BodyObject.self).filter("key == '24010910'").first
                            addedBody?.status = SynchStatusType.pending.rawValue
                        }
                        try? synchManager.synchronize { (value) in
                            expect(value).to(beTrue())
                            return
                        }
                        expect(datamanager.done["update"]).toEventually(beTrue())
                        expect(datamanager.done["list"]).toEventually(beTrue())
                    }

                    it("should update items") {

                        let realm = try? Realm(configuration: synchManager.configuration)

                        let addedBodyModel = DataMock.shared.addedBodyModel!
                        let conflictedBodyModel = DataMock.shared.conflictedBodyModel!
                        let bodyModelToUpdate = DataMock.shared.bodyModelToUpdate!
                        let bodyModelUpdated = DataMock.shared.bodyModelUpdated!

                        try? realm?.write {
                            let obj1 = BodyObject(model: addedBodyModel)!
                            obj1.status = SynchStatusType.pending.rawValue
                            realm?.add(obj1, update: false)

                            let obj2 = BodyObject(model: bodyModelToUpdate)!
                            obj2.status = SynchStatusType.pending.rawValue
                            realm?.add(obj2, update: true)

                            let obj3 = BodyObject(model: conflictedBodyModel)!
                            obj3.hashToken = "76248762837" //Invalid Token
                            obj3.status = SynchStatusType.pending.rawValue
                            realm?.add(obj3, update: true)
                        }
                        try? synchManager.synchronize { (value) in
                            expect(value).to(beTrue())
                            return
                        }

                        let obj1 = realm?.object(ofType: BodyObject.self, forPrimaryKey: addedBodyModel.key!)
                        expect(obj1?.status).to(equal(SynchStatusType.updated.rawValue))

                        let obj2 = realm?.object(ofType: BodyObject.self, forPrimaryKey: bodyModelUpdated.key!)
                        expect(obj2?.status).to(equal(SynchStatusType.updated.rawValue))

                        let obj3 = realm?.object(ofType: BodyObject.self, forPrimaryKey: conflictedBodyModel.key!)
                        expect(obj3?.status).to(equal(SynchStatusType.updated.rawValue))
                    }
                }
            }

            context("sites") {

                it("should call datamanager sites") {
                    synchManager.sites { _ in

                    }
                    expect(datamanager.done["sites"]).toEventually(beTrue())
                }

                it("should update the item with a valid token") {

                    let realm = try? Realm(configuration: synchManager.configuration)
                    synchManager.sites { _ in

                    }
                    let objectsCount = realm?.objects(SiteObject.self).count
                    expect(objectsCount).to(be(77))

                    let object = realm?.object(ofType: SiteObject.self, forPrimaryKey: 1)
                    expect(object?.name).to(equal("Abingdon (A34/41 interchange - South of Oxford)"))
                    expect(object?.region).to(equal("South East"))

                }

                context("when response fails") {

                    it("should leave the data unchanged") {

                        let realm = try? Realm(configuration: synchManager.configuration)

                        let siteModel = DataMock.shared.siteModel!
                        try? realm?.write {
                            let obj1 = SiteObject(model: siteModel)!
                            realm?.add(obj1, update: false)
                        }

                        datamanager.isResponseNotNil = false
                        synchManager.datamanager = datamanager
                        synchManager.sites { _ in

                        }
                        let objectsCount = realm?.objects(SiteObject.self).count
                        expect(objectsCount).to(be(1))

                        let object = realm?.object(ofType: SiteObject.self, forPrimaryKey: 1)
                        expect(object?.name).to(equal("Abingdon (A34/41 interchange - South of Oxford)"))
                        expect(object?.region).to(equal("South East"))

                    }
                }

            }
        }
    }
}
