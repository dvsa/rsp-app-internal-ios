//
//  DateUtilities.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 12/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

extension Calendar {

    static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }
}

extension Date {
    var zeroSeconds: Date {
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calender.date(from: dateComponents) ?? self
    }

    var dateOnlyUTC: Date {
        let dateComponents = Calendar.utc.dateComponents([.year, .month, .day], from: self)
        return Calendar.utc.date(from: dateComponents) ?? self
    }

    var dateOnly: Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: dateComponents) ?? self
    }

    var dvsaDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }

    var dvsaDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, hh:mma"
        return formatter.string(from: self)
    }

    static func dateFromDvsaString(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: string)
    }

    var dvsaLastSyncDateTimeString: String {

        let today = Date().dateOnly
        let interval = self.timeIntervalSince(today)
        let yesteday: TimeInterval = 60*60*24

        if interval > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mma"
            return "Today at \(formatter.string(from: self))"
        }

        if interval > -yesteday {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mma"
            return "Yesterday at \(formatter.string(from: self))"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy at hh:mma"
        return formatter.string(from: self)
    }

    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    static var todayUTC: Date {
        let date = Date().dateOnlyUTC
        return date
    }
}
