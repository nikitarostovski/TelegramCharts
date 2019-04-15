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
    private lazy var calcItem: DispatchWorkItem = DispatchWorkItem { [weak self] in
        self?.calcQueue.sync {
            self?.recalcCharts()
            self?.applyChartChanges(animated: false)
        }
    }
    private lazy var animatedCalcItem: DispatchWorkItem = DispatchWorkItem { [weak self] in
        self?.calcQueue.sync {
            self?.recalcCharts()
            self?.applyChartChanges(animated: true)
        }
    }

    private let yResetInterval: TimeInterval = 0.25
    private let animationDuration: TimeInterval = 0.25
    private var viewportAnimator = Animator()
    
    private var lastRecalcYDate: Date?
    private var needRecalcY = true
    
    private var insets: UIEdgeInsets = .zero
    
    private (set) var range: ClosedRange<CGFloat>
    
    private (set) weak var graph: Graph?
    private (set) var chartDataSources: [ChartDataSource]
    private (set) var yAxisDataSources: [YAxisDataSource]
    private (set) var xAxisDataSource: XAxisDataSource
    
    var dates: [Date]
    
    var selectionUpdateHandler: (() -> Void)?
    var resetGridValuesHandler: (() -> Void)?
    var redrawHandler: (() -> Void)? {
        didSet {
            startRecalc(animated: false)
        }
    }

    init(graph: Graph, range: ClosedRange<CGFloat>) {
        self.graph = graph
        self.dates = graph.dates
        self.range = range
        self.xAxisDataSource = XAxisDataSource(dates: graph.dates, viewport: Viewport())
        self.yAxisDataSources = []
        self.chartDataSources = [ChartDataSource]()
        graph.charts.forEach {
            chartDataSources.append(sourceForChart($0))
        }

        if graph.yScaled && graph.charts.count == 2 {
            let left = YAxisDataSource(graph: graph, sources: [chartDataSources.first!])
            let right = YAxisDataSource(graph: graph, sources: [chartDataSources.last!])
            left.alignment = .left
            right.alignment = .right
            left.resetHandler = { [weak self] in
                self?.recalcYAxis()
                self?.applyChartChanges(animated: true)
            }
            right.resetHandler = { [weak self] in
                self?.recalcYAxis()
                self?.applyChartChanges(animated: true)
            }
            self.yAxisDataSources = [left, right]
        } else {
            let left = YAxisDataSource(graph: graph, sources: chartDataSources)
            left.resetHandler = { [weak self] in
                self?.recalcYAxis()
                self?.applyChartChanges(animated: true)
            }
            self.yAxisDataSources = [left]
        }
    }
    
    func setEdgeInsets(insets: UIEdgeInsets) {
        self.insets = insets
        startRecalc(animated: false)
    }
    
    func setNormalizedTextWidth(textWidth: CGFloat) {
        xAxisDataSource.textWidth = textWidth
    }

    private func recalcCharts() {
        guard let graph = graph else { return }
        xAxisDataSource.updateViewportX(range: range)
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
                    if source.visible {
                        offsets = sourceOffsets
                    }
                } else if source.visible {
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
                guard $0.visible else { return }
                if maxViewport == nil {
                    maxViewport = $0.targetViewport
                    return
                }
                maxViewport!.yLo = min(maxViewport!.yLo, $0.targetViewport.yLo)
                maxViewport!.yHi = max(maxViewport!.yHi, $0.targetViewport.yHi)
            }
            if maxViewport != nil {
                chartDataSources.forEach {
                    $0.targetViewport.yLo = maxViewport!.yLo
                    $0.targetViewport.yHi = maxViewport!.yHi
                }
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
        recalcYAxis()
    }
    
    private func recalcYAxis() {
        if lastRecalcYDate == nil {
            lastRecalcYDate = Date(timeIntervalSince1970: 0)
        }
        if Date().timeIntervalSince(lastRecalcYDate!) < yResetInterval {
            needRecalcY = true
            return
        }
        var needReset = false
        yAxisDataSources.forEach {
            $0.updateViewport()
            if $0.needReset {
                needReset = true
            }
        }
        if needReset {
            yAxisDataSources.forEach {
                $0.resetValues()
            }
            resetGrid()
            lastRecalcYDate = Date()
            needRecalcY = false
        }
    }
    
    private func applyChartChanges(animated: Bool) {
        chartDataSources.forEach { source in
            source.viewport.xLo = source.targetViewport.xLo
            source.viewport.xHi = source.targetViewport.xHi
        }
        if animated {
            viewportAnimator.animate(duration: animationDuration, easing: .easeOutCubic, update: { [weak self] (phase) in
                guard let self = self else { return }
                self.calcQueue.sync {
                    self.chartDataSources.forEach { source in
                        source.opacity = source.lastOpacity + (source.targetOpacity - source.lastOpacity) * phase
                        source.viewport.yLo = source.lastViewport.yLo + (source.targetViewport.yLo - source.lastViewport.yLo) * phase
                        source.viewport.yHi = source.lastViewport.yHi + (source.targetViewport.yHi - source.lastViewport.yHi) * phase
                        source.mapViewport.yLo = source.mapLastViewport.yLo + (source.mapTargetViewport.yLo - source.mapLastViewport.yLo) * phase
                        source.mapViewport.yHi = source.mapLastViewport.yHi + (source.mapTargetViewport.yHi - source.mapLastViewport.yHi) * phase
                    }
                    self.yAxisDataSources.forEach { source in
                        source.viewport.yLo = source.lastViewport.yLo + (source.targetViewport.yLo - source.lastViewport.yLo) * phase
                        source.viewport.yHi = source.lastViewport.yHi + (source.targetViewport.yHi - source.lastViewport.yHi) * phase
                        source.values.forEach { $0.opacity = $0.lastOpacity + ($0.targetOpacity - $0.lastOpacity) * phase }
                        source.lastValues.forEach { $0.opacity = $0.lastOpacity + ($0.targetOpacity - $0.lastOpacity) * phase }
                    }
                    self.redraw()
                }
            }, finish: { [weak self] in
                guard let self = self else { return }
                self.calcQueue.sync {
                    self.chartDataSources.forEach { source in
                        source.lastOpacity = source.opacity
                        source.lastViewport = source.viewport
                        source.mapLastViewport = source.mapViewport
                    }
                    self.yAxisDataSources.forEach { source in
                        source.lastViewport = source.viewport
                        source.values.forEach { $0.lastOpacity = $0.opacity }
                        source.lastValues.forEach { $0.lastOpacity = $0.opacity }
                    }
                    if self.needRecalcY {
                        self.recalcYAxis()
                        self.applyChartChanges(animated: true)
                    }
                    self.redraw()
                }
            }, cancel: { [weak self] in
                guard let self = self else { return }
                self.calcQueue.sync {
                    self.chartDataSources.forEach { source in
                        source.lastOpacity = source.opacity
                        source.lastViewport = source.viewport
                        source.mapLastViewport = source.mapViewport
                    }
                    self.yAxisDataSources.forEach { source in
                        source.lastViewport = source.viewport
                        source.values.forEach { $0.lastOpacity = $0.opacity }
                        source.lastValues.forEach { $0.lastOpacity = $0.opacity }
                    }
                    self.redraw()
                }
            })
        } else {
            chartDataSources.forEach { source in
                source.lastOpacity = source.opacity
                source.opacity = source.targetOpacity
                source.lastViewport = source.viewport
                source.viewport = source.targetViewport
                source.mapLastViewport = source.mapViewport
                source.mapViewport = source.mapTargetViewport
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
    
    func setChartsVisibility(visibilities: [Bool]) {
        guard visibilities.count == chartDataSources.count else { return }
        for i in visibilities.indices {
            let source = chartDataSources[i]
            source.visible = visibilities[i]
        }
        deselect()
        startRecalc(animated: true)
    }
    
    func changeLowerBound(newLow: CGFloat) {
        self.range = newLow ... range.upperBound
        deselect()
        startRecalc(animated: true)
    }
    
    func changeUpperBound(newUp: CGFloat) {
        self.range = range.lowerBound ... newUp
        deselect()
        startRecalc(animated: true)
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        deselect()
        startRecalc(animated: true)
    }
    
    func trySelect(x: CGFloat) {
        chartDataSources.forEach {
            let newSelection = Int(($0.viewport.xLo + x * $0.viewport.width) * CGFloat($0.xIndices.count))
            guard newSelection >= 0, newSelection < $0.xIndices.count else { return }
            $0.selectedIndex = newSelection
        }
        selectionUpdateHandler?()
    }
    
    func deselect() {
        chartDataSources.forEach {
            $0.selectedIndex = nil
        }
        selectionUpdateHandler?()
    }
    
    private func startRecalc(animated: Bool) {
        if animated {
            animatedCalcItem.perform()
        } else {
            calcItem.perform()
        }
    }
}
