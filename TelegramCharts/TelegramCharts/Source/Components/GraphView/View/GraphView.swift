//
//  GraphView.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    var insets: UIEdgeInsets = .zero
    private var chartBounds: CGRect = .zero
    private var textWidth: CGFloat
    
    private weak var dataSource: GraphDataSource?
    private var lineWidth: CGFloat
    private var isMap: Bool
    
    private var xTintView: TintView?
    
    private var charts: [ChartLayerProtocolType]
    private var yGrids: [YGridLayer]
    private var yTitles: [YTextLayer]
    private var xGrid: XGridLayer?
    private var xTitles: XTextLayer?
    
    init(dataSource: GraphDataSource, lineWidth: CGFloat, insets: UIEdgeInsets, isMap: Bool, textWidth: CGFloat) {
        self.textWidth = textWidth
        self.isMap = isMap
        self.lineWidth = lineWidth
        self.dataSource = dataSource
        self.charts = [ChartLayerProtocolType]()
        self.yGrids = []
        self.yTitles = []
        self.insets = insets
        
        if !isMap {
            for ySource in dataSource.yAxisDataSources {
                self.yTitles.append(YTextLayer(source: ySource))
                self.yGrids.append(YGridLayer(source: ySource))
            }
            self.xTitles = XTextLayer(source: dataSource.xAxisDataSource, textWidth: textWidth)
            self.xGrid = XGridLayer()
            self.xTintView = TintView()
            self.xTintView?.backgroundColor = UIColor.clear
        }
        
        super.init(frame: .zero)
        dataSource.chartDataSources.forEach {
            guard $0.chart.type != .line else { return }
            let chartLayer = layerForChart($0)
            layer.addSublayer(chartLayer)
            charts.append(chartLayer)
        }
        yGrids.forEach { layer.addSublayer($0) }
        dataSource.chartDataSources.forEach {
            guard $0.chart.type == .line else { return }
            let chartLayer = layerForChart($0)
            layer.addSublayer(chartLayer)
            charts.append(chartLayer)
        }
        yTitles.forEach { layer.addSublayer($0) }
        if let xTitles = xTitles {
            self.layer.addSublayer(xTitles)
        }
        if let xGrid = xGrid {
            self.layer.addSublayer(xGrid)
        }
        if let xTintView = xTintView {
            addSubview(xTintView)
        }
        backgroundColor = .clear
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartBounds = bounds.inset(by: insets)
        charts.forEach { $0.frame = chartBounds }
        yGrids.forEach { $0.frame = chartBounds }
        yTitles.forEach { $0.frame = chartBounds }
        
        let xTitlesBounds = CGRect(x: insets.left, y: bounds.height - insets.bottom, width: bounds.width - insets.left - insets.right, height: insets.bottom)
        xTitles?.frame = xTitlesBounds
        xTitles?.updatePositions()
        xGrid?.frame = xTitlesBounds
        xGrid?.redraw()
        xTintView?.frame = CGRect(x: 0, y: xTitlesBounds.minY, width: bounds.width, height: xTitlesBounds.height)
        redraw()
    }
    
    func redraw() {
        guard bounds != .zero else { return }
        charts.forEach { $0.update() }
        yGrids.forEach { $0.updatePositions() }
        yTitles.forEach { $0.updatePositions() }
        xTitles?.updatePositions()
    }
    
    func resetGridValues() {
        guard bounds != .zero else { return }
        yGrids.forEach { $0.resetValues() }
        yTitles.forEach { $0.resetValues() }
    }
    
    private func layerForChart(_ source: ChartDataSource) -> ChartLayerProtocolType {
        switch source.chart.type {
        case .line:
            return LineChartLayer(source: source, lineWidth: lineWidth)
        case .bar:
            return BarChartLayer(source: source, lineWidth: lineWidth)
        case .area:
            return AreaChartLayer(source: source, lineWidth: lineWidth)
        }
    }
    
    func updateChartAlpha() {
        /*for chartIndex in charts.indices {
            charts[chartIndex].updateAlpha(alpha: dataSource.charts[chartIndex].visible ? 1 : 0)
        }*/
    }
    
    // MARK: Touches, Selection
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let pos = touches.first!.location(in: self)
        guard chartBounds.contains(pos) else {
            hideSelection()
            return
        }
        
        let x = (pos.x - chartBounds.origin.x) / chartBounds.size.width
        showSelection(x: x)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let pos = touches.first!.location(in: self)
        guard chartBounds.contains(pos) else {
            return
        }
        let x = (pos.x - chartBounds.origin.x) / chartBounds.size.width
        moveSelection(x: x)
    }
    
    private func showSelection(x: CGFloat) {
        dataSource.trySelect(x: x)
        guard let index = dataSource.selectionIndex, let data = dataSource.plateData else {
            hideSelection()
            return
        }
        selection.setData(data: data)
        selection.show(x: x)
        yGrid.showSelection(x: x)
        for chart in charts {
//            line.select(index: index)
        }
    }
    
    private func moveSelection(x: CGFloat) {
        dataSource.trySelect(x: x)
        guard let index = dataSource.selectionIndex, let data = dataSource.plateData else {
            hideSelection()
            return
        }
        selection.setData(data: data)
        selection.move(toX: x)
        yGrid.moveSelection(x: x)
        for chart in charts {
            chart.moveSelection(index: index)
        }
    }
    
    private func hideSelection() {
        selection.hide()
        yGrid.hideSelection()
        for chart in charts {
            chart.hideSelection()
        }
    }*/
}
