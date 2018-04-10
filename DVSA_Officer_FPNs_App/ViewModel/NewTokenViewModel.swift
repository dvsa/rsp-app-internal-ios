//
//  NewTokenViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 09/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class NewTokenViewModel: BaseViewModel {

    var model: NewTokenModel = NewTokenModel(value: nil) {
        didSet {
            validateDocument()
        }
    }

    var isRefValid: Bool = false
    var isVehRegValid: Bool = false
    var isDateValid: Bool = false
    var isAmountValid: Bool = false

    override init() {
        super.init()
        model.penaltyType = PenaltyType.fpn
    }

    func isValidDocument() -> Bool {
        return isRefValid && isVehRegValid && isDateValid && isAmountValid
    }

    func updateRefNumber(refNumber: String?) {
        model.referenceNo = refNumber ?? ""
        validateDocument()
    }

    func updateVehicleReg(vehicleRegNo: String?) {

        model.vehicleRegNo = vehicleRegNo ?? ""
        validateDocument()
    }

    func updateDateTime(dateTime: Date) {
        model.dateTime = dateTime
        validateDocument()
    }

    func updatePenaltyAmount(penaltyAmount: String?) {
        model.penaltyAmount = penaltyAmount ?? ""
        validateDocument()
    }

    func updateDocumentType(index: Int) {
        if 0...2 ~= index,
            let penaltyType = PenaltyType(rawValue: UInt8(index)) {
            model.penaltyType = penaltyType
        }
        validateDocument()
    }

    func immobReferenceComponents() -> [String] {
        //MUST RETURN [String].count = 3
        let substringSet = model.referenceNo.split(separator: "-")
        guard substringSet.count == 4 else {
                return  [model.referenceNo, "", ""]
        }
        let firstNumber = String(substringSet[0])
        let secondNumber = String(substringSet[1])
        let thirdNumber = String(substringSet[2])
        let values = [firstNumber, secondNumber, thirdNumber]
        return values
    }

    func validateDocument() {
        isRefValid = TokenValidator.validateRefNumber(string: model.referenceNo)
        isVehRegValid = TokenValidator.validateVehicleReg(string: model.vehicleRegNo)
        if let date = model.dateTime {
            isDateValid = TokenValidator.validateDate(string: date.dvsaDateString)
        }
        isAmountValid = TokenValidator.validatePenaltyAmount(string: model.penaltyAmount)
    }

    func invalidInfoMessage() -> String {
        var message = ""
        if !isRefValid && model.referenceNo.count > 0 {
            message += "\u{2022} Please recheck the reference number\n"
        }
        if !isVehRegValid && model.vehicleRegNo.count > 0 {
            message += "\u{2022} Please recheck the registration number\n"
        }
        if !isDateValid && model.dateTime != nil {
            message += "\u{2022} Please recheck the date\n"
        }
        if !isAmountValid && model.penaltyAmount.count > 0 {
            message += "\u{2022} Please recheck the penalty amount\n"
        }
        return message
    }
}
