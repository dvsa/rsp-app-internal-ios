//
//  TokenValidator.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class TokenValidator: NSObject {

    static func validateRefNumber(string: String) -> Bool {
        let regex = Regex(regex: DetailsRowData.refNumber.regexString)
        let regexMatch = (regex.firstMatchedText(text: string) == string)
        let firstNotZero = string.first != nil && string.first != "0"
        return regexMatch && firstNotZero
    }

    static func isValidIMReference(text: String?, component: UInt8) -> Bool {
        guard let text = text else {
            return false
        }
        switch component {
        case 0, 2:
            return Int(text) != nil && text.count <= 6 && Int(text) ?? 0 > 0 && text.first != "0"
        case 1:
            let valid = (Int(text) == 0 || Int(text) == 1) && text.count == 1
            return valid
        default:
            return false
        }
    }

    static func validateVehicleReg(string: String) -> Bool {
        let regex = Regex(regex: DetailsRowData.vehicleReg.filteredRegexString)
        return (regex.firstMatchedText(text: string) == string)
    }

    static func validateDate(string: String) -> Bool {
        let regex = Regex(regex: DetailsRowData.date.regexString)
        let dateFormatValid = (regex.firstMatchedText(text: string) == string)
        var dateValid = false
        if let date = Date.dateFromDvsaString(string: string),
            let earliestDate = Calendar.current.date(byAdding: .day, value: -29, to: Date()) {
            dateValid = date <= Date() && date >= earliestDate
        }
        return dateFormatValid && dateValid
    }

    static func validatePenaltyAmount(string: String) -> Bool {
        let regex = Regex(regex: DetailsRowData.penaltyAmount.filteredRegexString)
        return (regex.firstMatchedText(text: string) == string)
    }

    static func validateDateAndRef(string: String, indexPath: IndexPath) -> Bool {
        if let type = DetailsRowData(rawValue: indexPath.row) {
            switch type {
            case .date:
                return TokenValidator.validateDate(string: string)
            case .refNumber:
                return TokenValidator.validateRefNumber(string: string)
            default:
                return true
            }
        }
        return false
    }
}
