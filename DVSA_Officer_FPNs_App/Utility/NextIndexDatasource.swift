//
//  LocalPersistencyManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class NextIndexOperation: NSObject {
    let currentOffset: TimeInterval
    let nextID: String?
    let nextOffset: TimeInterval?
    let isStarted: Bool

    override init() {
        self.currentOffset = 0
        self.nextID = nil
        self.nextOffset = nil
        self.isStarted = false
    }

    init(currentOffset: TimeInterval, nextOffset: TimeInterval?, nextID: String?, isStarted: Bool) {
        self.currentOffset = currentOffset
        self.nextOffset = nextOffset
        self.nextID = nextID
        self.isStarted = isStarted
    }

    override var description: String {
        return "{ currentOffset: \(currentOffset),\n" +
        "nextOffset: \(String(describing: nextOffset)),\n" +
        "nextID: \(String(describing: nextID)),\n" +
        "isStarted: \(isStarted) }"
    }
}

protocol NextIndexDatasource: class {

    func reset()
    func setNextIndexOperation(operation: NextIndexOperation)
    func updateNextIndexOperation()
    func getNextIndexOperation() -> NextIndexOperation
    func updateOffsetIfNeeded(offset: TimeInterval?)
}

class LocalNextIndexDatasource: NextIndexDatasource {

    var persistentDatabase: ObjectsDataSource = PersistentDataSource()

    struct NextIndexKey {
        static let currentOffsetKey = "dvsa_currentOffsetKey"
        static let nextIDKey = "dvsa_nextIDKey"
        static let nextOffsetKey = "dvsa_nextOffsetKey"
        static let isStartedKey = "dvsa_isStartedKey"
    }

    func reset() {
        let resetOperation = NextIndexOperation(currentOffset: 0, nextOffset: nil, nextID: nil, isStarted: false)
        setNextIndexOperation(operation: resetOperation)
    }

    func setNextIndexOperation(operation: NextIndexOperation) {
        UserDefaults.standard.set(operation.nextID, forKey: NextIndexKey.nextIDKey)
        UserDefaults.standard.set(operation.nextOffset, forKey: NextIndexKey.nextOffsetKey)
        UserDefaults.standard.set(operation.currentOffset, forKey: NextIndexKey.currentOffsetKey)
        UserDefaults.standard.set(operation.isStarted, forKey: NextIndexKey.isStartedKey)
        log.verbose(operation)
        UserDefaults.standard.synchronize()
    }

    func updateNextIndexOperation() {
        let nextID = UserDefaults.standard.string(forKey: NextIndexKey.nextIDKey)
        let isStarted = UserDefaults.standard.bool(forKey: NextIndexKey.isStartedKey)
        if !isStarted && nextID == nil,
            let offset = persistentDatabase.maxOffset() {
            let nextOperation = NextIndexOperation(currentOffset: offset - 60,
                                                  nextOffset: nil,
                                                  nextID: nil,
                                                  isStarted: false)
            setNextIndexOperation(operation: nextOperation)
        }
    }

    func getNextIndexOperation() -> NextIndexOperation {

        let currentOffset = UserDefaults.standard.double(forKey: NextIndexKey.currentOffsetKey)
        let nextID = UserDefaults.standard.string(forKey: NextIndexKey.nextIDKey)
        let nextOffset = UserDefaults.standard.double(forKey: NextIndexKey.nextOffsetKey)
        let isStarted = UserDefaults.standard.bool(forKey: NextIndexKey.isStartedKey)
        let operation = NextIndexOperation(currentOffset: currentOffset,
                                           nextOffset: nextOffset == 0 ? nil : nextOffset,
                                          nextID: nextID,
                                          isStarted: isStarted)

        return operation
    }

    func updateOffsetIfNeeded(offset: TimeInterval?) {
        DispatchQueue(label: "LocalNextIndexDatasource", qos: .default).sync {
            let nextIndexOp = self.getNextIndexOperation()
            if let offset = offset,
                offset < nextIndexOp.currentOffset,
                nextIndexOp.isStarted == false,
                nextIndexOp.nextID == nil,
                nextIndexOp.nextOffset == nil {
                let newNextIndexOp = NextIndexOperation(currentOffset: offset, nextOffset: nil, nextID: nil, isStarted: false)
                log.info("using offset from notification")
                self.setNextIndexOperation(operation: newNextIndexOp)
            }
        }
    }
}
