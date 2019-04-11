//
//  LineChartDataSource.swift
//  TelegramCharts
//
//  Created by SBRF on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class AreaChartValueDataSource {
    var value: Int
    var offset: Int
    
    var sumValue: Int
    
    init(_ value: Int) {
        self.value = value
        self.sumValue = value
        self.offset = 0
    }
}

class AreaChartDataSource: ChartDataSource {
    
    var yValues = [AreaChartValueDataSource]()
    
    override func updateViewportX(range: ClosedRange<CGFloat>) {
        let newViewport = ChartViewport()
        newViewport.xLo = range.lowerBound
        newViewport.xHi = range.upperBound
        viewport = newViewport
    }
    
    override func updatePointsX() {
        yValues = [AreaChartValueDataSource]()
        let lastIndex = chart.values.count - 1
        
        lo = Int(viewport.xLo * CGFloat(lastIndex) - 0.5)
        hi = Int(viewport.xHi * CGFloat(lastIndex) + 0.5)
        lo = max(lo, 0)
        hi = min(hi, lastIndex)
        
        xIndices = []
        for i in lo ... hi {
            let xNorm = CGFloat(i) / CGFloat(chart.values.count - 1)
            xIndices.append(xNorm)
            yValues.append(AreaChartValueDataSource(chart.values[i]))
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
        viewport.yLo = 0
        viewport.yHi = CGFloat(maxValue)
    }
    
    override func getOffsets() -> [Int] {
        return yValues.map { $0.value }
    }
    
    override func setSumValues(_ sums: [Int]) {
        yValues.indices.forEach {
            yValues[$0].sumValue = sums[$0]
        }
        viewport.yLo = 0
        viewport.yHi = 1
    }
}
