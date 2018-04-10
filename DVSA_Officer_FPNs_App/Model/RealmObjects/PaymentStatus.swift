//
//  PaymentStatus.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

enum PaymentStatus: UInt8 {
    case unpaid = 0
    case paid = 1

    static func value(from string: String?) -> PaymentStatus? {
        guard let string = string else {
            return nil
        }
        switch string {
        case "PAID":
            return .paid
        case "UNPAID":
            return .unpaid
        default:
            return nil
        }
    }

    func toString() -> String {
        switch self {
        case .paid:
            return "PAID"
        case .unpaid:
            return "UNPAID"
        }
    }
}

func == (lhs: PaymentStatus, rhs: PaymentStatus) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

extension DocumentObject {
    func getPaymentStatus() -> PaymentStatus? {

        guard self.paymentStatus >= 0 else {
            return nil
        }
        let penaltyTypeUInt8 = UInt8(self.paymentStatus)
        return PaymentStatus(rawValue: penaltyTypeUInt8)
    }

    func setPaymentStatus(paymentStatus: PaymentStatus) {
        self.paymentStatus = Int8(paymentStatus.rawValue)
    }
}
