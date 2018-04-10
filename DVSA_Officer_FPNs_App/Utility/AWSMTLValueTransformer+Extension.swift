//
//  AWSMTLValueTransformer+Extension.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

extension AWSMTLValueTransformer {

    public static func timeIntervalSince1970JSONTransformer() -> ValueTransformer {
        let privateForwardBlock: AWSMTLValueTransformerBlock? = { timeInterval in
            guard let timeInterval = timeInterval as? NSNumber else {
                return ValueTransformer()
            }
            return Date(timeIntervalSince1970: timeInterval.doubleValue)
        }
        let privateReverseBlock: AWSMTLValueTransformerBlock? = { date in
            guard let date = date as? Date else {
                return ValueTransformer()
            }
            return NSNumber(value: date.timeIntervalSince1970)
        }
        return AWSMTLValueTransformer.reversibleTransformer(forwardBlock: privateForwardBlock, reverse: privateReverseBlock)
    }
}
