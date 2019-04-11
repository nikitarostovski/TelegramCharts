//
//  LineChartDataSource.swift
//  TelegramCharts
//
//  Created by SBRF on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class LineChartValueDataSource {
    var value: Int
    
    init(_ value: Int) {
        self.value = value
    }
}

class LineChartDataSource: ChartDataSource {
    
    var yValues = [LineChartValueDataSource]()
    
    override func updateViewportX(range: ClosedRange<CGFloat>) {
        targetViewport.xLo = range.lowerBound
        targetViewport.xHi = range.upperBound
    }
    
    override func updatePointsX() {
        yValues = [LineChartValueDataSource]()
        let lastIndex = chart.values.count - 1
        
        lo = Int(targetViewport.xLo * CGFloat(lastIndex) - 0.5)
        hi = Int(targetViewport.xHi * CGFloat(lastIndex) + 0.5)
        lo = max(lo, 0)
        hi = min(hi, lastIndex)
        
        xIndices = []
        for i in lo ... hi {
            let xNorm = CGFloat(i) / CGFloat(chart.values.count - 1)
            xIndices.append(xNorm)
            yValues.append(LineChartValueDataSource(chart.values[i]))
        }
    }
    
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
