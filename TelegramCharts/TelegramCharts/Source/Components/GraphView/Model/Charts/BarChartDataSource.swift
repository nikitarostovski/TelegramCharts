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
        for i in yValues.indices {
            var lowValue = 0
            if let offsets = offsets {
                lowValue = offsets[i]
            }
            yValues[i].offset = lowValue
        }
    }
    
    override func updateViewportY() {
        var maxValue: Int = yValues[loVis].offset + yValues[loVis].value
        for i in loVis ... hiVis {
            maxValue = max(maxValue, yValues[i].offset + yValues[i].value)
        }
        targetViewport.yLo = 0
        targetViewport.yHi = CGFloat(maxValue)
    }
    
    override func getOffsets() -> [Int] {
        return yValues.map { $0.value }
    }
}
