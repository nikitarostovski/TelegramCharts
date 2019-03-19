//
//  Date+Formatter.swift
//  TelegramCharts
//
//  Created by Rost on 15/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

extension Date {

    func yearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }

    func monthDayShortString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: self)
    }
}
