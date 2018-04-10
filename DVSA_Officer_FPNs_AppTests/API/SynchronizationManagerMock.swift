//
//  SynchronizationManagerMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 08/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class SynchronizationManagerMock: SynchronizationDelegate {

    var lastUpdate: Date?

    var done = TestDone()
    var isValidResponse = true

    func delete(item: AWSBodyModel, completion: @escaping (Bool) -> Void) {
        done["delete"] = true
        completion(isValidResponse)
    }

    func uploadPending(items: [AWSBodyModel], completion:@escaping (Bool) -> Void) {
        done["uploadPending"] = true
    }

    func download(completion:@escaping (Bool) -> Void) {
        done["download"] = true
        lastUpdate = Date()
        completion(isValidResponse)
    }

    func synchronize(completion:@escaping (Bool) -> Void) throws {
        done["synchronize"] = true
        completion(isValidResponse)
    }

    func sites(completion:@escaping (Bool) -> Void) {
        done["sites"] = true
        completion(isValidResponse)
    }

    func isSyncRequired() -> Bool {
        return isValidResponse
    }

    static func getKey() -> Data {
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")
        return keyData as Data
    }

    static func setup() {
    }
}
