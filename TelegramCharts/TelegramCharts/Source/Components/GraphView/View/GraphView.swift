//
//  GraphView.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

//typealias XGridLayerProtocolType = (XGridLayerProtocol & CALayer)
//typealias YGridLayerProtocolType = (YGridLayerProtocol & CALayer)

class GraphView: UIView {
    
    private var insetTop: CGFloat = 0
    private var insetBottom: CGFloat = 0
    private var chartBounds: CGRect = .zero

    private weak var dataSource: GraphDataSource?
    private var lineWidth: CGFloat
    private var gridVisible: Bool
    private var isMap: Bool
    
    private var charts: [ChartLayerProtocolType]
    private var yGrids: [YGridLayer]
    private var yTitles: [YTextLayer]
//    private var xGrid: XGridLayerProtocolType
    
    init(dataSource: GraphDataSource, lineWidth: CGFloat, isMap: Bool) {
        self.isMap = isMap
        if !isMap {
            insetTop = 32
            insetBottom = 16
        }
        self.gridVisible = !isMap
        self.lineWidth = lineWidth
        self.dataSource = dataSource
        self.charts = [ChartLayerProtocolType]()
        self.yGrids = []
        self.yTitles = []
        
        for ySource in dataSource.yAxisDataSources {
            self.yTitles.append(YTextLayer(source: ySource))
            self.yGrids.append(YGridLayer(source: ySource))
        }
//        self.xGrid = XGridLayer()
        
        super.init(frame: .zero)
        dataSource.chartDataSources.forEach {
            guard $0.chart.type != .line else { return }
            let chartLayer = layerForChart($0)
            layer.addSublayer(chartLayer)
            charts.append(chartLayer)
        }
        yGrids.forEach { layer.addSublayer($0) }
//        self.layer.addSublayer(xGrid)
        dataSource.chartDataSources.forEach {
            guard $0.chart.type == .line else { return }
            let chartLayer = layerForChart($0)
            layer.addSublayer(chartLayer)
            charts.append(chartLayer)
        }
        yTitles.forEach { layer.addSublayer($0) }
        backgroundColor = .clear
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartBounds = CGRect(x: 0, y: insetTop, width: bounds.width, height: bounds.height - insetTop - insetBottom)
        charts.forEach { $0.frame = chartBounds }
        yGrids.forEach { $0.frame = chartBounds }
        yTitles.forEach { $0.frame = chartBounds }
        redraw()
        /*selection.frame = chartBounds
        yGrid.frame = chartBounds
        yGrid.resize()
        xGrid.frame = CGRect(x: 0, y: bounds.height - insetBottom, width: bounds.width, height: insetBottom)
        xGrid.resize()*/
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
    
    func redraw() {
        guard bounds != .zero else { return }
        charts.forEach { $0.update() }
        yGrids.forEach { $0.update() }
        yTitles.forEach { $0.update() }
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
