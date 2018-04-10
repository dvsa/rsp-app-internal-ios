//
//  UInt8+Extensions.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

// MARK: TimeInterval utils

extension TimeInterval {

    init?(from: String) {
        //DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ""
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        let enUSPOSIXLocale: Locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPOSIXLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        guard let value = dateFormatter.date(from: from)?.timeIntervalSince1970 else {
            return nil
        }
        self = value
    }

}

// MARK: UInt8 utils

/**

 Convert a Type to a Little-Endian [UInt8]

 @value a value of type T

 @return a Little-Endian [UInt8]

 ```
 let test16: [UInt8] = toByteArray(UInt16(1))
 //[1,0]
 let test32: [UInt8] = toByteArray(UInt32(256))
 //[0, 1, 0, 0]
 let test64: [UInt8] = toByteArray(UInt64(4584397))
 //[205, 243, 69, 0, 0, 0, 0, 0]
 ```
 */
func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafePointer(to: &value) {
        $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
            Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
        }
    }
}

/**

 Revert a Type from a Little-Endian [UInt8]

 @value a primitive type
 @T a type
 @return a T value

```
 let fromTest16 = fromByteArray([1,0], UInt16.self)
 //1
 let fromTest32 = fromByteArray([0, 1, 0, 0], UInt32.self)
 //256
 let fromTest64 = fromByteArray([205, 243, 69, 0, 0, 0, 0, 0], UInt64.self)
 //4584397
```
*/
func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
    return value.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }
}

extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: subSize).map({ (startIndex) -> [Element] in
            let endIndex = (startIndex.advanced(by: subSize) > self.count) ? self.count-startIndex : subSize
            return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
        })
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }

    // From http://stackoverflow.com/a/40278391
    init?(fromHexEncodedString string: String) {

        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(uint: UInt16) -> UInt8? {
            switch uint {
            case 0x30 ... 0x39:
                return UInt8(uint - 0x30)
            case 0x41 ... 0x46:
                return UInt8(uint - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(uint - 0x61 + 10)
            default:
                return nil
            }
        }

        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for char in string.utf16 {
            guard let val = decodeNibble(uint: char) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
}
