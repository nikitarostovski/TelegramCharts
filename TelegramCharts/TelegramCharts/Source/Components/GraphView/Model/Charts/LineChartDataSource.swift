//
//  LineChartDataSource.swift
//  TelegramCharts
//
//  Created by SBRF on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class LineChartDataSource: ChartDataSource {
    
    override func updatePointsY(offsets: [Int]?) {
        for i in lo ... hi {
            let valueSource = yValues[i - lo]
            valueSource.value = chart.values[i]
        }
    }
    
    override func updateViewportY() {
        var minValue: Int = yValues[0].value
        var maxValue: Int = yValues[0].value
        for i in lo ... hi {
            minValue = min(minValue, yValues[i - lo].value)
            maxValue = max(maxValue, yValues[i - lo].value)
        }
        targetViewport.yLo = CGFloat(minValue)
        targetViewport.yHi = CGFloat(maxValue)
    }
}
