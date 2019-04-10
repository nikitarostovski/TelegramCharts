//
//  GraphDataSource.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 08/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphDataSource {

    private (set) var range: ClosedRange<CGFloat>
    private (set) var chartDataSources: [ChartDataSource]
    
    var dates: [Date]
    var selectionIndex: Int?
    var redrawHandler: (() -> Void)?

    init(graph: Graph, range: ClosedRange<CGFloat>) {
        self.dates = graph.dates
        self.range = range
        self.chartDataSources = [ChartDataSource]()
        graph.charts.forEach {
            let source = ChartDataSource(chart: $0, viewport: ChartViewport(), visible: true)
            chartDataSources.append(source)
        }
        recalc()
    }

    private func recalc() {
        var maxViewport: ChartViewport? = nil
        chartDataSources.forEach {
            $0.updateVisibleRange(range: range)
            if maxViewport == nil {
                maxViewport = $0.viewport
                return
            }
            maxViewport!.xLo = min(maxViewport!.xLo, $0.viewport.xLo)
            maxViewport!.yLo = min(maxViewport!.yLo, $0.viewport.yLo)
            maxViewport!.xHi = max(maxViewport!.xHi, $0.viewport.xHi)
            maxViewport!.yHi = max(maxViewport!.yHi, $0.viewport.yHi)
        }
        if maxViewport != nil {
            chartDataSources.forEach {
                guard !$0.chart.yScaled else { return }
                $0.viewport = maxViewport!
            }
        }
    }
    
    private func redraw() {
        redrawHandler?()
    }
    
    func changeLowerBound(newLow: CGFloat) {
        self.range = newLow ... range.upperBound
        recalc()
        redraw()
    }
    
    func changeUpperBound(newUp: CGFloat) {
        self.range = range.lowerBound ... newUp
        recalc()
        redraw()
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        recalc()
        redraw()
    }
}
