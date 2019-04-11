//
//  GraphDataSource.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 08/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphDataSource {

    private let animationDuration: TimeInterval = 0.25
    private var viewportAnimator = Animator()
    
    private (set) var range: ClosedRange<CGFloat>
    
    private (set) weak var graph: Graph?
    private (set) var chartDataSources: [ChartDataSource]
    private (set) var yAxisDataSource: YAxisDataSource
    private var yViewMode: YAxisViewMode
    
    var dates: [Date]
    var selectionIndex: Int?
    var redrawHandler: (() -> Void)? {
        didSet {
            recalc(animated: false)
        }
    }

    init(graph: Graph, range: ClosedRange<CGFloat>) {
        self.graph = graph
        self.dates = graph.dates
        self.range = range
        
        self.yViewMode = graph.yScaled && graph.charts.count == 2 ? [.left, .right] : [.left]
        let yTextMode: YValueTextMode = graph.percentage ? .percent : .value
        self.yAxisDataSource = YAxisDataSource(viewMode: yViewMode, textMode: yTextMode)
        
        self.chartDataSources = [ChartDataSource]()
        graph.charts.forEach {
            chartDataSources.append(sourceForChart($0))
        }
    }

    private func recalc(animated: Bool = true) {
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
                    maxViewport = $0.targetViewport
                    return
                }
                maxViewport!.yLo = min(maxViewport!.yLo, $0.targetViewport.yLo)
                maxViewport!.yHi = max(maxViewport!.yHi, $0.targetViewport.yHi)
            }
            chartDataSources.forEach {
                $0.targetViewport.yLo = maxViewport!.yLo
                $0.targetViewport.yHi = maxViewport!.yHi
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
        
        var yLeftSources: [ChartDataSource]?
        var yRightSources: [ChartDataSource]?
        if yViewMode.contains(.left), yViewMode.contains(.right), chartDataSources.count > 1 {
            yLeftSources = [chartDataSources.first!]
            yRightSources = [chartDataSources.last!]
        } else if yViewMode.contains(.left), !yViewMode.contains(.right), !graph.yScaled {
            yLeftSources = chartDataSources
        } else if yViewMode.contains(.right), let lastSource = chartDataSources.last {
            yRightSources = [lastSource]
        } else if let firstSource = chartDataSources.first {
            yLeftSources = [firstSource]
        }
        yAxisDataSource.updatePoints(leftSource: yLeftSources, rightSource: yRightSources)
        
        if animated {
            chartDataSources.forEach { source in
                source.viewport.xLo = source.targetViewport.xLo
                source.viewport.xHi = source.targetViewport.xHi
            }
            viewportAnimator.animate(duration: animationDuration, easing: AnimationEasingType.easeOutCubic, update: { [weak self] (phase) in
                guard let self = self else { return }
                self.chartDataSources.forEach { source in
                    source.viewport.yLo = source.lastViewport.yLo + (source.targetViewport.yLo - source.lastViewport.yLo) * phase
                    source.viewport.yHi = source.lastViewport.yHi + (source.targetViewport.yHi - source.lastViewport.yHi) * phase
                }

                self.redraw()
            }, finish: { [weak self] in
                guard let self = self else { return }
                self.chartDataSources.forEach { source in
                    source.lastViewport = source.viewport
                }
            })
        } else {
            chartDataSources.forEach { source in
                source.lastViewport = source.viewport
                source.viewport = source.targetViewport
            }
            redraw()
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
    }
    
    func changeUpperBound(newUp: CGFloat) {
        self.range = range.lowerBound ... newUp
        recalc()
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        recalc()
    }
}
