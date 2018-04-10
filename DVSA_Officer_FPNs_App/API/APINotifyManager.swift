//
//  APINotifyManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 16/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

protocol APINotifyManagerProtocol {
    var notifyService: APINotifyServiceProtcol { get set }
    func sendSMS(item: AWSNotifySMSModel, completion: @escaping (Bool) -> Void)
    func sendEmail(item: AWSNotifyEmailModel, completion: @escaping (Bool) -> Void)
}

class APINotifyManager: APINotifyManagerProtocol {

    static let shared = APINotifyManager()

    var notifyService: APINotifyServiceProtcol = AWSMobileNotifyAPIClient.default()

    func sendSMS(item: AWSNotifySMSModel, completion: @escaping (Bool) -> Void) {
        notifyService.sendSMS(body: item).continueWith { (task) -> Void in
            if task.error == nil {
                completion(true)
                log.info("SMS Sent")
            } else {
                log.error(task.error)
                completion(false)
            }
            return
        }
    }

    func sendEmail(item: AWSNotifyEmailModel, completion: @escaping (Bool) -> Void) {

        notifyService.sendEmail(body: item).continueWith { (task) -> Void in
            if task.error == nil {
                completion(true)
                log.info("Email Sent")
            } else {
                log.error(task.error)
                completion(false)
            }
            return
        }
    }
}
