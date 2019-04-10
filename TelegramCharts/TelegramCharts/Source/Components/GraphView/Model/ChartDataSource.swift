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
    var visible: Bool
    var chart: Chart
    
    init(chart: Chart, viewport: ChartViewport, visible: Bool) {
        self.visible = visible
        self.chart = chart
        self.viewport = viewport
    }
    
    func updateVisibleRange(range: ClosedRange<CGFloat>) {
        let newViewport = ChartViewport()
        newViewport.xLo = range.lowerBound
        newViewport.xHi = range.upperBound
        
        let lastIndex = chart.values.count - 1
        let lo = max(Int(viewport.xLo * CGFloat(lastIndex) - 0.5), 0)
        let hi = min(Int(viewport.xHi * CGFloat(lastIndex) + 0.5), lastIndex)
        
        var minValue: Int = chart.values[lo]
        var maxValue: Int = chart.values[lo]
        for i in lo ... hi {
            minValue = min(minValue, chart.values[i])
            maxValue = max(maxValue, chart.values[i])
        }
        if chart.type == .line {
            newViewport.yLo = CGFloat(minValue)
        } else {
            newViewport.yLo = 0
        }
        newViewport.yHi = CGFloat(maxValue)
        viewport = newViewport
    }
}
