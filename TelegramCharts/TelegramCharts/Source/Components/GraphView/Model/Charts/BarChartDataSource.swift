//
//  LineChartDataSource.swift
//  TelegramCharts
//
//  Created by SBRF on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class BarChartValueDataSource {
    var value: Int
    var offset: Int
    
    init(_ value: Int) {
        self.value = value
        self.offset = 0
    }
}

class BarChartDataSource: ChartDataSource {
    
    var yValues = [BarChartValueDataSource]()
    
    override func updateViewportX(range: ClosedRange<CGFloat>) {
        targetViewport.xLo = range.lowerBound
        targetViewport.xHi = range.upperBound
    }
    
    override func updatePointsX() {
        yValues = [BarChartValueDataSource]()
        let lastIndex = chart.values.count - 1
        
        lo = Int(targetViewport.xLo * CGFloat(lastIndex) - 0.5)
        hi = Int(targetViewport.xHi * CGFloat(lastIndex) + 0.5)
        lo = max(lo, 0)
        hi = min(hi, lastIndex)
        
        xIndices = []
        for i in lo ... hi {
            let xNorm = CGFloat(i) / CGFloat(chart.values.count - 1)
            xIndices.append(xNorm)
            yValues.append(BarChartValueDataSource(chart.values[i]))
        }
    }
    
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
