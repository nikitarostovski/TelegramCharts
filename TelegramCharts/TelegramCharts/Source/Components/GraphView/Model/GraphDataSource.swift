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
    private (set) weak var graph: Graph?
    
    var dates: [Date]
    var selectionIndex: Int?
    var redrawHandler: (() -> Void)?

    init(graph: Graph, range: ClosedRange<CGFloat>) {
        self.graph = graph
        self.dates = graph.dates
        self.range = range
        self.chartDataSources = [ChartDataSource]()
        graph.charts.forEach {
            chartDataSources.append(sourceForChart($0))
        }
        recalc()
    }

    private func recalc() {
        guard let graph = graph else { return }
        chartDataSources.forEach {
            $0.updateViewportX(range: range)
            $0.updatePointsX()
        }
        if graph.stacked {
            var offsets: [Int]?
            chartDataSources.forEach { source in
                source.updatePointsY(offsets: offsets)
                let sourceOffsets = source.getOffsets()
                if offsets == nil {
                    offsets = sourceOffsets
                } else {
                    offsets!.indices.forEach { i in
                        offsets![i] += sourceOffsets[i]
                    }
                }
            }
        }
        chartDataSources.forEach {
            $0.updateViewportY()
        }
        if !graph.yScaled || graph.stacked {
            var maxViewport: ChartViewport? = nil
            chartDataSources.forEach {
                if maxViewport == nil {
                    maxViewport = $0.viewport
                    return
                }
                maxViewport!.yLo = min(maxViewport!.yLo, $0.viewport.yLo)
                maxViewport!.yHi = max(maxViewport!.yHi, $0.viewport.yHi)
            }
            chartDataSources.forEach {
                $0.viewport = maxViewport!
            }
        }
        if graph.percentage {
            var sums = [Int]()
            chartDataSources.forEach { source in
                if sums.count == 0 {
                    sums = Array(source.lo ... source.hi).map { _ in 0 }
                }
                for i in source.lo ... source.hi {
                    sums[i - source.lo] += source.chart.values[i]
                }
            }
            chartDataSources.forEach { source in
                source.setSumValues(sums)
            }
        }
    }
    
    private func redraw() {
        redrawHandler?()
    }
    
    private func sourceForChart(_ chart: Chart) -> ChartDataSource {
        switch chart.type {
        case .line:
            return LineChartDataSource(chart: chart, viewport: ChartViewport(), visible: true)
        case .bar:
            return BarChartDataSource(chart: chart, viewport: ChartViewport(), visible: true)
        case .area:
            return AreaChartDataSource(chart: chart, viewport: ChartViewport(), visible: true)
        }
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
