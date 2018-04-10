//
//  NotificationUtils.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 07/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationUtils: NSObject {

    static func silentOffset(userInfo: [AnyHashable: Any]) -> TimeInterval? {
        if let offset = userInfo["offset"] as? TimeInterval,
            let site = userInfo["site"] as? Int,
            site == 0 {
            return offset
        }
        return nil
    }

    static func notificationRequest(userInfo: [AnyHashable: Any], siteCode: Int) -> UNNotificationRequest? {

        if let site = userInfo["site"] as? Int,
            let refNo = userInfo["refNo"] as? String,
            let regNo = userInfo["regNo"] as? String,
            let type = userInfo["type"] as? String,
            let amount = userInfo["amount"] as? Int,
            let status = userInfo["status"] as? String,
            status == "PAID",
            site == siteCode {

            let penaltyType = PenaltyType.value(from: type)
            let title = "Reg: " + regNo + " - Paid"
            let body = String(format: "%@: %@ (£%d) has been paid",
                              penaltyType?.toExtendedString() ?? "",
                              refNo,
                              amount)

            let notification = UNMutableNotificationContent()
            notification.title = title
            notification.body = body
            notification.userInfo = userInfo

            let request = UNNotificationRequest(identifier: "TokenPaidNotification", content: notification, trigger: nil)
            return request
        }
        return nil
    }
}
