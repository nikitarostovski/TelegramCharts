//
//  LineChartDataSource.swift
//  TelegramCharts
//
//  Created by SBRF on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class AreaChartDataSource: ChartDataSource {
    
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
        
        if yValues.count > 0 {
            var maxMapValue: Int = yValues.first!.offset + yValues.first!.value
            for i in yValues.indices {
                maxMapValue = max(maxMapValue, yValues[i].offset + yValues[i].value)
            }
            mapTargetViewport.yLo = 0
            mapTargetViewport.yHi = CGFloat(maxMapValue)
        }
    }
    
    override func getOffsets() -> [Int] {
        return yValues.map { $0.value }
    }
    
    override func setSumValues(_ sums: [Int]) {
        yValues.indices.forEach {
            yValues[$0].sumValue = sums[$0]
        }
        mapTargetViewport.yLo = 0
        mapTargetViewport.yHi = 1
        targetViewport.yLo = 0
        targetViewport.yHi = 1
    }
}
