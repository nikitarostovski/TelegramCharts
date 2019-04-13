//
//  Date+Formatter.swift
//  TelegramCharts
//
//  Created by Rost on 15/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum DateFormat: String {
    case month = "MMM"
    case day = "d"
    case year = "YYYY"
    case monthDay = "MMM d"
    case dayMonth = "d MMM"
    case weekdayDayMonthYear = "EEE, d MMM yyyy"
}

extension Date {

    func string(format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        var result: String
        
        if format == .monthDay || format == .dayMonth {
            dateFormatter.dateFormat = DateFormat.month.rawValue
            var m = dateFormatter.string(from: self)
            let start = m.index(m.startIndex, offsetBy: 0)
            let end = m.index(m.startIndex, offsetBy: 2)
            m = String(m[start ... end]).capitalized
            
            dateFormatter.dateFormat = DateFormat.day.rawValue
            let d = dateFormatter.string(from: self)
            
            if format == .monthDay {
                result = "\(m) \(d)"
            } else {
                result = "\(d) \(m)"
            }
        } else {
            dateFormatter.dateFormat = format.rawValue
            result = dateFormatter.string(from: self)
        }
        
        return result
    }
}
