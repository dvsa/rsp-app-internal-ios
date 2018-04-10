//
//  OCRCameraSessionViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 22/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

enum DetailsRowData: Int {

    case refNumber = 0, vehicleReg = 1, date = 2, penaltyAmount = 3

    var title: String {
        switch self {
        case .refNumber:
            return "Reference: "
        case .vehicleReg:
            return "Vehicle reg: "
        case .date:
            return "Date: "
        case .penaltyAmount:
            return "Amount (£): "
        }
    }

    var resultViewTitle: String {
        switch self {
        case .refNumber:
            return "Reference number"
        case .vehicleReg:
            return "Vehicle registration"
        case .date:
            return "Date"
        case .penaltyAmount:
            return "Penalty amount (£)"
        }
    }

    var regexString: String {
        switch self {
        case .refNumber:
            return "(\\d{12,13}|\\d{1,6}-[0,1]-[1-9]\\d{0,5}-IM)"
        case .vehicleReg:
            return "(cle\\s+[A-Z0-9]{1,10}\\s+|No:\\s+[A-Z0-9]{1,10}\\s+)"
        case .date:
            return "\\d{1,2}[\\/\\s]\\d{1,2}[\\/\\s]\\d{4}"
        case .penaltyAmount:
            return "£[1-9]\\d{1,3}"
        }
    }

    var filteredRegexString: String {
        switch self {
        case .refNumber:
            return DetailsRowData.refNumber.regexString
        case .vehicleReg:
            return "[A-Z0-9]{1,10}"
        case .date:
            return DetailsRowData.date.regexString
        case .penaltyAmount:
            return "[1-9]\\d{1,3}"
        }
    }

    var stringToRemove: [String] {
        switch self {
        case .vehicleReg:
            return [" ", "\n", "cle", "No:"]
        case .penaltyAmount:
            return ["£"]
        default:
            return []
        }
    }
}

class OCRCameraSessionViewModel: BaseViewModel {

    let ocrEngine = TesseractOCREngine()
    var numberOfRows: Int { return 4  }
    var model: NewTokenModel = NewTokenModel(value: nil)

    init(model: NewTokenModel) {
        super.init()
        self.model = model
    }

    func cellTitleForSelectedIndex(indexPath: IndexPath) -> String? {
        return DetailsRowData(rawValue: indexPath.row)?.title
    }

    func cellValueForSelectedIndex(indexPath: IndexPath) -> String? {
        if let type = DetailsRowData(rawValue: indexPath.row) {
            switch type {
            case .refNumber:
                return model.referenceNo
            case .vehicleReg:
                return model.vehicleRegNo
            case .date:
                return model.dateTime?.dvsaDateString ?? ""
            case .penaltyAmount:
                return model.penaltyAmount
            }
        }
        return nil
    }

    func resultTitleForSelectedIndex(indexPath: IndexPath) -> String? {
        return DetailsRowData(rawValue: indexPath.row)?.resultViewTitle
    }

    func clearValueAtIndex(indexPath: IndexPath) {
        if let type = DetailsRowData(rawValue: indexPath.row) {
            switch type {
            case .refNumber:
                model.referenceNo = ""
                model.penaltyType = .fpn
            case .vehicleReg:
                model.vehicleRegNo = ""
            case .date:
                model.dateTime = nil
            case .penaltyAmount:
                model.penaltyAmount = ""
            }
        }
    }

    func changeValueAtIndex(indexPath: IndexPath, value: String) {
        if let type = DetailsRowData(rawValue: indexPath.row) {
            switch type {
            case .refNumber:
                model.referenceNo = value
                model.penaltyType = value.contains("IM") ? .immobilization : .fpn
            case .vehicleReg:
                model.vehicleRegNo = value
            case .date:
                model.dateTime = Date.dateFromDvsaString(string: value)
            case .penaltyAmount:
                model.penaltyAmount = value
            }
        }
    }

    func getNextEmptyFieldIndex() -> IndexPath {
        var index: Int = 0
        if model.referenceNo == "" {
            index = 0
        } else if model.vehicleRegNo == "" {
            index = 1
        } else if model.dateTime == nil {
            index = 2
        } else if model.penaltyAmount == "" {
            index = 3
        }
        return IndexPath(row: index, section: 0)
    }

    func getTextFromImage(image: UIImage, indexPath: IndexPath) -> String? {
        let result = ocrEngine.getTextFromImage(image: image)
        if let regex = regexString(for: indexPath),
            result.count > 0 {
            let filter = Regex(regex: regex)
            let filteredResult = filter.firstMatchedText(text: result)

            // Solution for detecting format of "vehicle XXXXX " and "Reg No: XXXXX "
            // following code will remove the prefix and suffix to detect the vehicle registration
            if let textType = DetailsRowData(rawValue: indexPath.row),
                (textType == .vehicleReg || textType == .penaltyAmount),
                let subStringSet = DetailsRowData(rawValue: indexPath.row)?.stringToRemove,
                let resultText = filteredResult {
                return Regex.removeRegexSubStrings(text: resultText, stringsToRemove: subStringSet)
            }

            return filteredResult
        }
        return nil
    }

    func regexString(for indexPath: IndexPath) -> String? {
        return DetailsRowData(rawValue: indexPath.row)?.regexString
    }
}
