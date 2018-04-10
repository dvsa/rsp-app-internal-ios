//
//  LocalNextIndexDatasourceSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import Foundation

@testable import DVSA_Officer_FPNs_App

class LocalNextIndexDatasourceSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("LocalNextIndexDatasource") {

            var operation: NextIndexOperation!
            var operationStarted: NextIndexOperation!
            let offset: TimeInterval = 1516898361
            let nextOffset: TimeInterval = 1516898461
            let nextID = "12345678980123_FPN"
            var persistentDatabase: PersistentDataSourceMock!

            beforeEach {
                UserDefaults.resetStandardUserDefaults()
                operation = NextIndexOperation(currentOffset: offset, nextOffset: nil, nextID: nil, isStarted: false)
                operationStarted = NextIndexOperation(currentOffset: offset, nextOffset: nextOffset, nextID: nextID, isStarted: true)
                persistentDatabase = PersistentDataSourceMock()
            }

            context("setNextIndexOperation") {

                it("should save NextIndexOperation") {

                    LocalNextIndexDatasource().setNextIndexOperation(operation: operation)

                    var currentOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.currentOffsetKey)
                    var nextID = UserDefaults.standard.string(forKey: LocalNextIndexDatasource.NextIndexKey.nextIDKey)
                    var nextOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.nextOffsetKey)
                    var isStarted = UserDefaults.standard.bool(forKey: LocalNextIndexDatasource.NextIndexKey.isStartedKey)

                    expect(currentOffset).to(equal(1516898361))
                    expect(nextID).to(beNil())
                    expect(nextOffset).to(equal(0))
                    expect(isStarted).to(beFalse())

                    LocalNextIndexDatasource().setNextIndexOperation(operation: operationStarted)

                    currentOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.currentOffsetKey)
                    nextID = UserDefaults.standard.string(forKey: LocalNextIndexDatasource.NextIndexKey.nextIDKey)
                    nextOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.nextOffsetKey)
                    isStarted = UserDefaults.standard.bool(forKey: LocalNextIndexDatasource.NextIndexKey.isStartedKey)

                    expect(currentOffset).to(equal(1516898361))
                    expect(nextID).to(equal("12345678980123_FPN"))
                    expect(nextOffset).to(equal(1516898461))
                    expect(isStarted).to(beTrue())

                }
            }

            context("updateNextIndexOperation") {

                beforeEach {
                    LocalNextIndexDatasource().setNextIndexOperation(operation: operation)
                }

                context("should") {

                    it("not update NextIndexOperation") {

                        LocalNextIndexDatasource().setNextIndexOperation(operation: operationStarted)

                        let localNIDS = LocalNextIndexDatasource()
                        persistentDatabase.maxOffsetMock = 1516898561
                        localNIDS.persistentDatabase = persistentDatabase

                        localNIDS.updateNextIndexOperation()

                        let currentOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.currentOffsetKey)
                        let nextID = UserDefaults.standard.string(forKey: LocalNextIndexDatasource.NextIndexKey.nextIDKey)
                        let nextOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.nextOffsetKey)
                        let isStarted = UserDefaults.standard.bool(forKey: LocalNextIndexDatasource.NextIndexKey.isStartedKey)

                        expect(currentOffset).to(equal(1516898361))
                        expect(nextID).to(equal("12345678980123_FPN"))
                        expect(nextOffset).to(equal(1516898461))
                        expect(isStarted).to(beTrue())
                    }

                    it("update NextIndexOperation with max - 60") {

                        let localNIDS = LocalNextIndexDatasource()
                        persistentDatabase.maxOffsetMock = 1516898561
                        localNIDS.persistentDatabase = persistentDatabase

                        localNIDS.updateNextIndexOperation()

                        let currentOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.currentOffsetKey)
                        let nextID = UserDefaults.standard.string(forKey: LocalNextIndexDatasource.NextIndexKey.nextIDKey)
                        let nextOffset = UserDefaults.standard.double(forKey: LocalNextIndexDatasource.NextIndexKey.nextOffsetKey)
                        let isStarted = UserDefaults.standard.bool(forKey: LocalNextIndexDatasource.NextIndexKey.isStartedKey)

                        expect(currentOffset).to(equal(1516898561 - 60))
                        expect(nextID).to(beNil())
                        expect(nextOffset).to(equal(0))
                        expect(isStarted).to(beFalse())
                    }
                }
            }

            context("getNextIndexOperation") {

                beforeEach {
                    LocalNextIndexDatasource().setNextIndexOperation(operation: operation)
                    LocalNextIndexDatasource().setNextIndexOperation(operation: operationStarted)
                }

                it("should get NextIndexOperation") {
                    let nextOp = LocalNextIndexDatasource().getNextIndexOperation()
                    expect(nextOp.currentOffset).to(equal(1516898361))
                    expect(nextOp.nextID).to(equal("12345678980123_FPN"))
                    expect(nextOp.nextOffset).to(equal(1516898461))
                    expect(nextOp.isStarted).to(beTrue())

                }
            }

            context("reset") {

                beforeEach {
                    LocalNextIndexDatasource().setNextIndexOperation(operation: operation)
                }

                it("should get NextIndexOperation") {
                    LocalNextIndexDatasource().reset()
                    let nextOp = LocalNextIndexDatasource().getNextIndexOperation()
                    expect(nextOp.currentOffset).to(equal(0))
                    expect(nextOp.nextID).to(beNil())
                    expect(nextOp.nextOffset).to(beNil())
                    expect(nextOp.isStarted).to(beFalse())
                }
            }

            context("updateOffsetIfNeeded") {

                beforeEach {
                    LocalNextIndexDatasource().setNextIndexOperation(operation: operation)
                }

                it("offset is gt") {
                    LocalNextIndexDatasource().updateOffsetIfNeeded(offset: 1516898461)
                    let nextOp = LocalNextIndexDatasource().getNextIndexOperation()
                    expect(nextOp.currentOffset).to(equal(1516898361))
                    expect(nextOp.nextID).to(beNil())
                    expect(nextOp.nextOffset).to(beNil())
                    expect(nextOp.isStarted).to(beFalse())
                }

                it("offset is lt") {
                    LocalNextIndexDatasource().updateOffsetIfNeeded(offset: 1516898261)
                    let nextOp = LocalNextIndexDatasource().getNextIndexOperation()
                    expect(nextOp.currentOffset).to(equal(1516898261))
                    expect(nextOp.nextID).to(beNil())
                    expect(nextOp.nextOffset).to(beNil())
                    expect(nextOp.isStarted).to(beFalse())
                }
            }
        }
    }
}
