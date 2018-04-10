//
//  APINotifyManagerMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 16/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
@testable import DVSA_Officer_FPNs_App

class APINotifyManagerMock: APINotifyManagerProtocol {

    var notifyService: APINotifyServiceProtcol

    var done = TestDone()

    var bodyModel = DataMock.shared.bodyModel
    var bodyModelUpdated = DataMock.shared.bodyModelUpdated
    var bodyModelToUpdate = DataMock.shared.bodyModelToUpdate
    var addedBodyModel = DataMock.shared.addedBodyModel
    var conflictedBodyModel = DataMock.shared.conflictedBodyModel
    var bodyListModel = DataMock.shared.bodyListModel
    var opResultListModel = DataMock.shared.opResultListModel
    var siteList = DataMock.shared.siteListModel
    var isResponseNotNil = true

    init(notifyService: APINotifyServiceProtcol) {
        self.notifyService = notifyService
    }

    func sendSMS(item: AWSNotifySMSModel, completion: @escaping (Bool) -> Void) {
        done["sendSMS"] = true
        completion(isResponseNotNil)
    }

    func sendEmail(item: AWSNotifyEmailModel, completion: @escaping (Bool) -> Void) {
        done["sendEmail"] = true
        completion(isResponseNotNil)
    }
}
