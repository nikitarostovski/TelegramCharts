//
//  LineChartDataSource.swift
//  TelegramCharts
//
//  Created by SBRF on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class BarChartDataSource: ChartDataSource {
    
    override func updatePointsY(offsets: [Int]?) {
        for i in lo ... hi {
            var lowValue = 0
            if let offsets = offsets {
                lowValue = offsets[i - lo]
            }
            let valueSource = yValues[i - lo]
            valueSource.offset = lowValue
            valueSource.value = chart.values[i]
        }
    }
    
    override func updateViewportY() {
        var maxValue: Int = yValues[0].offset + yValues[0].value
        for i in lo ... hi {
            maxValue = max(maxValue, yValues[i - lo].offset + yValues[i - lo].value)
        }
        targetViewport.yLo = 0
        targetViewport.yHi = CGFloat(maxValue)
    }
    
    override func getOffsets() -> [Int] {
        return yValues.map { $0.value }
    }
}
