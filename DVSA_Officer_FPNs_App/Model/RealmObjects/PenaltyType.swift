//
//  PenaltyType.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
enum PenaltyType: UInt8 {

    case fpn = 0
    case immobilization = 1
    case deposit = 2

    static func value(from string: String?) -> PenaltyType? {
        guard let string = string else {
            return nil
        }
        switch string {
        case "FPN":
            return .fpn
        case "IM":
            return .immobilization
        case "CDN":
            return .deposit
        default:
            return nil
        }
    }

    func toString() -> String {
        switch self {
        case .fpn:
            return "FPN"
        case .immobilization:
            return "IM"
        case .deposit:
            return "CDN"
        }
    }

    func toExtendedString() -> String {
        switch self {
        case .fpn:
            return "Fixed penalty"
        case .immobilization:
            return "Immobilisation"
        case .deposit:
            return "Court deposit"
        }
    }

}

func == (lhs: PenaltyType, rhs: PenaltyType) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

extension DocumentObject {
    func getPenaltyType() -> PenaltyType? {
        guard self.penaltyType >= 0 else {
            return nil
        }
        let penaltyTypeUInt8 = UInt8(self.penaltyType)
        return PenaltyType(rawValue: penaltyTypeUInt8)
    }
}
