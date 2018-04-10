//
//  DriverNotificationViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

enum DriverNotificationType {
    case sms
    case email
}

class DriverNotificationViewModel {
    internal var modelSMS: AWSNotifySMSModel?
    internal var modelEmail: AWSNotifyEmailModel?
    var type: DriverNotificationType
    var notifyManager: APINotifyManagerProtocol = APINotifyManager.shared

    init(type: DriverNotificationType, vehicleReg: String, location: String, amount: UInt16, token: String) {

        self.type = type
        switch type {
        case .email:
            modelEmail = AWSNotifyEmailModel()
            modelEmail?.amount = NSNumber(value: amount)
            modelEmail?.email = ""
            modelEmail?.token = token
            modelEmail?.vehicleReg = vehicleReg
            modelEmail?.location = location

        case .sms:
            modelSMS = AWSNotifySMSModel()
            modelSMS?.amount = NSNumber(value: amount)
            modelSMS?.phoneNumber = ""
            modelSMS?.token = token
            modelSMS?.vehicleReg = vehicleReg
            modelSMS?.location = location
        }
    }

    convenience init?(document: DocumentObject, type: DriverNotificationType) {

        guard let  regNo = document.vehicleDetails?.regNo,
            let amount = UInt16(document.penaltyAmount),
            let token = document.paymentToken,
            let location = document.placeWhereIssued else {
                return nil
        }
        self.init(type: type, vehicleReg: regNo, location: location, amount: amount, token: token)
    }

    func isValid(address: String) -> Bool {
        switch type {
        case .sms:
            return address.isValidPhoneNumber()
        case .email:
            return address.isValidEmail()
        }
    }

    func send(address: String, completion: @escaping (Bool) -> Void) {
        switch type {
        case .sms:
            self.sendSMS(phoneNumber: address, completion: completion)
        case .email:
            self.sendEmail(email: address, completion: completion)
        }
    }

    internal func sendSMS(phoneNumber: String, completion: @escaping (Bool) -> Void) {

        guard type == .sms,
            let model = modelSMS else {
            log.error("Invalid model")
            completion(false)
            return
        }

        model.phoneNumber = phoneNumber

        guard model.isValid() else {
            log.error("Invalid phone number")
            completion(false)
            return
        }

        notifyManager.sendSMS(item: model) { (result) in
            completion(result)
        }

    }

    internal func sendEmail(email: String, completion: @escaping (Bool) -> Void) {
        guard type == .email,
            let model = modelEmail else {
            log.error("Invalid model")
            completion(false)
            return
        }

        model.email = email

        guard model.isValid() else {
            log.error("Invalid email")
            completion(false)
            return
        }

        notifyManager.sendEmail(item: model) { (result) in
            completion(result)
        }
    }

    internal func invalidInfoMessage() -> String {
        switch type {
        case .email:
            return "Please recheck the email address is in the correct format (e.g. username@example.com)"
        case .sms:
            return "Please recheck the phone number is correct and that it includes the international prefix."
        }
    }
}
