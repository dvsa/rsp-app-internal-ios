//
//  RegExFilter.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

struct Regex {

    internal var regexString: String = ""

    init(regex: String) {
        regexString = regex
    }

    internal func regexMatches(text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regexString)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            log.error("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    internal func firstMatchedText(text: String) -> String? {
        let matches = regexMatches(text: text)
        return matches.count > 0 ? matches[0] : nil
    }

    static func removeRegexSubStrings(text: String, stringsToRemove: [String]) -> String {
        var resultText = text
        for subtext in stringsToRemove {
            resultText = resultText.replacingOccurrences(of: subtext, with: "")
        }
        return resultText
    }
}
