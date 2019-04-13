//
//  ChartDataSource.swift
//  TelegramCharts
//
//  Created by Rost on 10/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartValueDataSource {
    var value: Int
    var offset: Int
    var sumValue: Int
    
    init(_ value: Int) {
        self.value = value
        self.sumValue = value
        self.offset = 0
    }
}

class ChartDataSource {
    var viewport: Viewport
    var lastViewport: Viewport
    var targetViewport: Viewport
    var visible: Bool
    var chart: Chart
    
    var lo: Int
    var hi: Int
    var xIndices: [CGFloat]
    var yValues: [ChartValueDataSource]
    
    init(chart: Chart, viewport: Viewport, visible: Bool) {
        self.visible = visible
        self.chart = chart
        self.viewport = viewport
        self.lastViewport = viewport
        self.targetViewport = viewport
        self.xIndices = []
        self.yValues = []
        self.lo = 0
        self.hi = 0
    }
    
    func updateViewportX(range: ClosedRange<CGFloat>) {
        targetViewport.xLo = range.lowerBound
        targetViewport.xHi = range.upperBound
    }
    
    func updatePointsX() {
        yValues = [ChartValueDataSource]()
        let lastIndex = chart.values.count - 1
        
        lo = Int(targetViewport.xLo * CGFloat(lastIndex) - 0.5)
        hi = Int(targetViewport.xHi * CGFloat(lastIndex) + 0.5)
        lo = max(lo, 0)
        hi = min(hi, lastIndex)
        
        xIndices = []
        for i in lo ... hi {
            let xNorm = CGFloat(i) / CGFloat(lastIndex)
            xIndices.append(xNorm)
            yValues.append(ChartValueDataSource(chart.values[i]))
        }
    }
    
    func updatePointsY(offsets: [Int]?) { }
    
    func updateViewportY() { }
    
    func getOffsets() -> [Int] {
        return []
    }
    
    func setSumValues(_ sums: [Int]) { }
}
