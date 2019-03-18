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

        var maxValue: Int64 = 0
        for (name, points) in chart.columns {
            let type = chart.types[name]
            if type == "line" {
                maxValue = max(maxValue, points.max() ?? 0)
            }
        }

        for (name, values) in chart.columns {
            let type = chart.types[name]
            if type == "line" {
                guard let colorHex = chart.colors[name] else { continue }
                let normPoints = values.map { CGFloat($0) / CGFloat(maxValue) }
                let line = ChartLine(y: normPoints, color: UIColor(hexString: colorHex))
                lines.append(line)
            } else if type == "x" {
                let dates: [Date] = values.map { Date(timeIntervalSince1970: TimeInterval($0)) }
                grid = ChartGrid(xAxisData: dates, yAxisMaxNumber: maxValue)
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
