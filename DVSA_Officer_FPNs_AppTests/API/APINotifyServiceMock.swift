//
//  APINotifyServiceMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 16/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
@testable import DVSA_Officer_FPNs_App

class APINotifyServiceMock: APINotifyServiceProtcol {

    var isValidModel: Bool = true
    var error: Error?

    func setupWithError() {
        self.isValidModel = false
        self.error = NSError(domain: "Test", code: 100, userInfo: [:])
    }

    func sendSMS(body: AWSNotifySMSModel) -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: "OK" as NSString)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

    func sendEmail(body: AWSNotifyEmailModel) -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: "OK" as NSString)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }
}
