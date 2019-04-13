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
    var mapViewport: Viewport
    var mapLastViewport: Viewport
    var mapTargetViewport: Viewport
    
    var viewport: Viewport
    var lastViewport: Viewport
    var targetViewport: Viewport
    var visible: Bool
    var chart: Chart
    
    var lo: Int
    var hi: Int
    
    var loVis: Int
    var hiVis: Int
    
    var xIndices: [CGFloat]
    var yValues: [ChartValueDataSource]
    
    init(chart: Chart, viewport: Viewport, visible: Bool) {
        self.visible = visible
        self.chart = chart
        self.viewport = viewport
        self.lastViewport = viewport
        self.targetViewport = viewport
        self.xIndices = chart.values.indices.map { CGFloat($0) / CGFloat(chart.values.count - 1) }
        self.yValues = chart.values.map { ChartValueDataSource($0) }
        self.lo = 0
        self.hi = self.xIndices.count - 1
        self.loVis = lo
        self.hiVis = hi
        
        self.mapViewport = Viewport()
        self.mapLastViewport = Viewport()
        self.mapTargetViewport = Viewport()
        mapViewport.xLo = 0
        mapViewport.xHi = 1
        mapLastViewport.xLo = 0
        mapLastViewport.xHi = 1
        mapTargetViewport.xLo = 0
        mapTargetViewport.xHi = 1
    }
    
    func updateViewportX(range: ClosedRange<CGFloat>) {
        targetViewport.xLo = range.lowerBound
        targetViewport.xHi = range.upperBound
    }
    
    func updatePointsX(insetLeft: CGFloat, insetRight: CGFloat) {
        let lastIndex = chart.values.count - 1
        
        lo = Int(targetViewport.xLo * CGFloat(lastIndex) - 1)
        hi = Int(targetViewport.xHi * CGFloat(lastIndex) + 1)
        lo = max(lo, 0)
        hi = min(hi, lastIndex)
        
        loVis = Int((targetViewport.xLo - insetLeft) * CGFloat(lastIndex) - 1)
        hiVis = Int((targetViewport.xHi + insetRight) * CGFloat(lastIndex) + 1)
        loVis = max(loVis, 0)
        hiVis = min(hiVis, lastIndex)
    }
    
    func updatePointsY(offsets: [Int]?) { }
    
    func updateViewportY() { }
    
    func getOffsets() -> [Int] {
        return []
    }
    
    func setSumValues(_ sums: [Int]) { }
}
