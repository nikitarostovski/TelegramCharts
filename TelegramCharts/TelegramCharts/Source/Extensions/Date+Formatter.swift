//
//  Date+Formatter.swift
//  TelegramCharts
//
//  Created by Rost on 15/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum DateFormat: String {
    case year = "YYYY"
    case monthDay = "MMM d"
    case weekdayDayMonthYear = "EEE, d MMM yyyy"
}

extension Date {

    func string(format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
}
