//
//  ChartConverter.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 18/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ConversionCompletionHandler = ((lines: [ChartLine], dates: [Date])?) -> Void

class ChartConverter {

    static func convert(chart: Chart?, completion: ConversionCompletionHandler) {
        guard let chart = chart else {
            completion(nil)
            return
        }
        var lines = [ChartLine]()
        var dates = [Date]()

        for (name, values) in chart.columns {
            let type = chart.types[name]
            if type == "line" {
                guard let colorHex = chart.colors[name] else { continue }
                let line = (values: values, color: UIColor(hexString: colorHex), name: name)
                lines.append(line)
            } else if type == "x" {
                dates = values.map { Date(timeIntervalSince1970: TimeInterval($0 / 1000)) }
            }
        }
        completion((lines: lines, dates: dates))
    }
}
