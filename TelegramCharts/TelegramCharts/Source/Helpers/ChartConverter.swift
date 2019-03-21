//
//  ChartConverter.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 18/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ConversionCompletionHandler = ((lines: [ChartLine], grid: ChartGrid)?) -> Void

class ChartConverter {

    static func convert(chart: Chart?, completion: ConversionCompletionHandler) {
        guard let chart = chart else {
            completion(nil)
            return
        }
        var lines = [ChartLine]()
        var grid: ChartGrid?

        for (name, values) in chart.columns {
            let type = chart.types[name]
            if type == "line" {
                guard let colorHex = chart.colors[name] else { continue }
                let line = ChartLine(values: values, color: UIColor(hexString: colorHex), name: name)
                lines.append(line)
            } else if type == "x" {
                let dates: [Date] = values.map { Date(timeIntervalSince1970: TimeInterval($0)) }
                grid = ChartGrid(xAxisData: dates, yAxisMaxNumber: 1000)
            }
        }
        if let grid = grid {
            completion((lines: lines, grid: grid))
            return
        } else {
            completion(nil)
            return
        }
    }
}
