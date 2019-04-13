//
//  LineChartDataSource.swift
//  TelegramCharts
//
//  Created by SBRF on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class LineChartDataSource: ChartDataSource {
    
    override func updateViewportY() {
        var minValue: Int = yValues[loVis].value
        var maxValue: Int = yValues[hiVis].value
        for i in loVis ... hiVis {
            minValue = min(minValue, yValues[i].value)
            maxValue = max(maxValue, yValues[i].value)
        }
        targetViewport.yLo = CGFloat(minValue)
        targetViewport.yHi = CGFloat(maxValue)
        
        if yValues.count > 0 {
            var minMapValue: Int = yValues.first!.value
            var maxMapValue: Int = yValues.last!.value
            for i in yValues.indices {
                minMapValue = min(minMapValue, yValues[i].value)
                maxMapValue = max(maxMapValue, yValues[i].value)
            }
            mapTargetViewport.yLo = CGFloat(minMapValue)
            mapTargetViewport.yHi = CGFloat(maxMapValue)
        }
    }
}
