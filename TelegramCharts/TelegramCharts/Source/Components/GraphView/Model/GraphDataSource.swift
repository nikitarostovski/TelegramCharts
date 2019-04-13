//
//  GraphDataSource.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 08/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphDataSource {
    
    private let calcQueue = DispatchQueue.global(qos: .userInitiated)
    private var calcItem: DispatchWorkItem?

    private let animationDuration: TimeInterval = 0.25
    private var viewportAnimator = Animator()
    private var yAnimator = Animator()
    private var animationLock = false
    
    private var insets: UIEdgeInsets = .zero
    
    private (set) var range: ClosedRange<CGFloat>
    
    private (set) weak var graph: Graph?
    private (set) var chartDataSources: [ChartDataSource]
    private (set) var yAxisDataSources: [YAxisDataSource]
    private (set) var xAxisDataSource: XAxisDataSource
    
    var dates: [Date]
    var selectionIndex: Int?
    
    var resetGridValuesHandler: (() -> Void)?
    var redrawHandler: (() -> Void)? {
        didSet {
            self.calcItem?.cancel()
            self.calcItem = DispatchWorkItem { [weak self] in self?.calcQueue.sync { self?.recalc(animated: false) } }
            calcQueue.sync(execute: self.calcItem!)
        }
    }

    init(graph: Graph, range: ClosedRange<CGFloat>) {
        self.graph = graph
        self.dates = graph.dates
        self.range = range
        
        self.xAxisDataSource = XAxisDataSource(dates: graph.dates, viewport: Viewport())
        
        let yLeftDataSource = YAxisDataSource(graph: graph)
        self.yAxisDataSources = [yLeftDataSource]
        if graph.yScaled && graph.charts.count == 2 {
            let yRightDataSource = YAxisDataSource(graph: graph)
            self.yAxisDataSources.append(yRightDataSource)
            yLeftDataSource.alignment = .left
            yRightDataSource.alignment = .right
        }
        self.chartDataSources = [ChartDataSource]()
        graph.charts.forEach {
            chartDataSources.append(sourceForChart($0))
        }
    }
    
    func setEdgeInsets(insets: UIEdgeInsets) {
        self.insets = insets
        recalc(animated: false)
    }
    
    func setNormalizedTextWidth(textWidth: CGFloat) {
        xAxisDataSource.textWidth = textWidth
    }

    private func recalc(animated: Bool = true) {
        guard let graph = graph else { return }
        chartDataSources.forEach {
            $0.updateViewportX(range: range)
            $0.updatePointsX(insetLeft: insets.left, insetRight: insets.right)
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
            var maxViewport: Viewport? = nil
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
                    sums = Array(0 ..< source.yValues.count).map { _ in 0 }
                }
                for i in source.yValues.indices {
                    sums[i] += source.chart.values[i]
                }
            }
            chartDataSources.forEach { source in
                source.setSumValues(sums)
            }
        }
        xAxisDataSource.updateViewportX(range: range)
        updateYAxis()
        applyChanges(animated: animated)
    }
    
    private func updateYAxis() {
        yAxisDataSources.indices.forEach { i in
            var sources: [ChartDataSource]
            if yAxisDataSources.count == 1 {
                sources = chartDataSources
            } else {
                sources = [chartDataSources[i]]
            }
            yAxisDataSources[i].updateViewport(sources: sources)
            if !animationLock {
                yAxisDataSources[i].resetValues(sources: sources)
            }
        }
        if !animationLock {
            resetGrid()
        }
    }
    
    private func applyChanges(animated: Bool) {
        chartDataSources.forEach { source in
            source.viewport.xLo = source.targetViewport.xLo
            source.viewport.xHi = source.targetViewport.xHi
        }
        if animated {
            if !animationLock {
                animationLock = true
                calcQueue.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
                    self?.animationLock = false
//                    self?.updateYAxis()
                }
            }
            viewportAnimator.animate(duration: animationDuration, easing: .easeOutCubic, update: { [weak self] (phase) in
                guard let self = self else { return }
                self.chartDataSources.forEach { source in
                    source.viewport.yLo = source.lastViewport.yLo + (source.targetViewport.yLo - source.lastViewport.yLo) * phase
                    source.viewport.yHi = source.lastViewport.yHi + (source.targetViewport.yHi - source.lastViewport.yHi) * phase
                }
                self.yAxisDataSources.forEach { source in
                    source.viewport.yLo = source.lastViewport.yLo + (source.targetViewport.yLo - source.lastViewport.yLo) * phase
                    source.viewport.yHi = source.lastViewport.yHi + (source.targetViewport.yHi - source.lastViewport.yHi) * phase
                    source.values.forEach { $0.opacity = $0.lastOpacity + ($0.targetOpacity - $0.lastOpacity) * phase }
                    source.lastValues.forEach { $0.opacity = $0.lastOpacity + ($0.targetOpacity - $0.lastOpacity) * phase }
                }
                self.redraw()
            }, finish: { [weak self] in
                guard let self = self else { return }
                self.chartDataSources.forEach { source in
                    source.lastViewport = source.viewport
                }
                self.yAxisDataSources.forEach { source in
                    source.lastViewport = source.viewport
                    source.values.forEach { $0.lastOpacity = $0.opacity }
                    source.lastValues.forEach { $0.lastOpacity = $0.opacity }
                }
            })
        } else {
            animationLock = false
            chartDataSources.forEach { source in
                source.lastViewport = source.viewport
                source.viewport = source.targetViewport
            }
            yAxisDataSources.forEach { source in
                source.lastViewport = source.viewport
                source.viewport = source.targetViewport
                source.values.forEach { $0.opacity = $0.targetOpacity }
                source.lastValues.forEach { $0.opacity = $0.targetOpacity }
            }
            redraw()
        }
    }
    
    private func redraw() {
        DispatchQueue.main.async {
            self.redrawHandler?()
        }
    }
    
    private func resetGrid() {
        DispatchQueue.main.async {
            self.resetGridValuesHandler?()
        }
    }
    
    private func sourceForChart(_ chart: Chart) -> ChartDataSource {
        switch chart.type {
        case .line:
            return LineChartDataSource(chart: chart, viewport: Viewport(), visible: true)
        case .bar:
            return BarChartDataSource(chart: chart, viewport: Viewport(), visible: true)
        case .area:
            return AreaChartDataSource(chart: chart, viewport: Viewport(), visible: true)
        }
    }
    
    func changeLowerBound(newLow: CGFloat) {
        self.range = newLow ... range.upperBound
        self.calcItem?.cancel()
        self.calcItem = DispatchWorkItem { [weak self] in self?.calcQueue.sync { self?.recalc() } }
        calcQueue.sync(execute: self.calcItem!)
    }
    
    func changeUpperBound(newUp: CGFloat) {
        self.range = range.lowerBound ... newUp
        self.calcItem?.cancel()
        self.calcItem = DispatchWorkItem { [weak self] in self?.calcQueue.sync { self?.recalc() } }
        calcQueue.sync(execute: self.calcItem!)
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        self.calcItem?.cancel()
        self.calcItem = DispatchWorkItem { [weak self] in self?.calcQueue.sync { self?.recalc() } }
        calcQueue.sync(execute: self.calcItem!)
    }
}
