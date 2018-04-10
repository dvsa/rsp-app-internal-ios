//
//  String+URLEncode.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 06/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
extension String {

    /// Returns a new string made from the `String` by replacing all characters not in the unreserved
    /// character set (As defined by RFC3986) with percent encoded characters.

    func urlEncoded() -> String? {
        let allowedCharacters = CharacterSet.URLQueryParameterAllowedCharacterSet()
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

    func urlDecoded() -> String? {
        return self.removingPercentEncoding
    }

    func splitedBy(length: Int) -> [String] {
        var groups = [String]()
        var currentGroup = ""
        for index in self.indices {
            currentGroup.append(self[index])
            if currentGroup.count == length {
                groups.append(currentGroup)
                currentGroup = ""
            }
        }
        if currentGroup.count > 0 {
            groups.append(currentGroup)
        }
        return groups
    }

    func insert(separator: String, lenght: Int) -> String {
        let stringArray = self.splitedBy(length: lenght)
        return stringArray.joined(separator: separator)
    }

    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "^[\\+(00)][0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }

    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }

    func immobTokenRef(type: PenaltyType) -> String? {

        guard type == PenaltyType.immobilization else {
            return self
        }

        let substringSet = self.split(separator: "-")

        guard substringSet.count == 4,
            substringSet[0].count <= 6,
            substringSet[1].count == 1,
            Int(substringSet[1]) == 0 || Int(substringSet[1]) == 1,
            substringSet[2].count <= 6,
            let firstNumber = Int(substringSet[0]),
            let secondNumber = Int(substringSet[1]),
            let thirdNumber = Int(substringSet[2]) else {
                return nil
        }
        // final format of IM ref is 6 digit long of first number part
        // plus 1 digit long of second number part
        // plus fixed 6 digit long of the third part
        return String(format: "%06d%d%06d", firstNumber, secondNumber, thirdNumber)
    }
}

extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard self.count > limit else { return self }

        switch position {
        case .head:
            return leader + self.suffix(limit)
        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))

            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))

            return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
        case .tail:
            return self.prefix(limit) + leader
        }
    }
}

extension CharacterSet {

    /// Returns the character set for characters allowed in the individual parameters within a query URL component.
    ///
    /// The query component of a URL is the component immediately following a question mark (?).
    /// For example, in the URL `http://www.example.com/index.php?key1=value1#jumpLink`, the query
    /// component is `key1=value1`. The individual parameters of that query would be the key `key1`
    /// and its associated value `value1`.
    ///
    /// According to RFC 3986, the set of unreserved characters includes
    ///
    /// `ALPHA / DIGIT / "-" / "." / "_" / "~"`
    ///
    /// In section 3.4 of the RFC, it further recommends adding `/` and `?` to the list of unescaped characters
    /// for the sake of compatibility with some erroneous implementations, so this routine also allows those
    /// to pass unescaped.

    static func URLQueryParameterAllowedCharacterSet() -> CharacterSet {
        return self.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
    }

}
