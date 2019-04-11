//
//  ChartDataSource.swift
//  TelegramCharts
//
//  Created by Rost on 10/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDataSource {
    var viewport: ChartViewport
    var lastViewport: ChartViewport
    var targetViewport: ChartViewport
    var visible: Bool
    var chart: Chart
    
    var lo: Int
    var hi: Int
    var xIndices: [CGFloat]
    
    init(chart: Chart, viewport: ChartViewport, visible: Bool) {
        self.visible = visible
        self.chart = chart
        self.viewport = viewport
        self.lastViewport = viewport
        self.targetViewport = viewport
        self.xIndices = []
        self.lo = 0
        self.hi = 0
    }
    
    func updateViewportX(range: ClosedRange<CGFloat>) { }
    
    func updatePointsX() { }
    
    func updatePointsY(offsets: [Int]?) { }
    
    func updateViewportY() { }
    
    func getOffsets() -> [Int] {
        return []
    }
    
    func setSumValues(_ sums: [Int]) { }
}
