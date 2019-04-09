//
//  GraphView.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ChartLayerProtocolType = (ChartLayerProtocol & CALayer)
typealias XGridLayerProtocolType = (XGridLayerProtocol & CALayer)
typealias YGridLayerProtocolType = (YGridLayerProtocol & CALayer)
typealias SelectionLayerProtocolType = (SelectionLayerProtocol & CALayer)

protocol GraphDataSourceProtocol {

    var range: ClosedRange<CGFloat> { get }

    var charts: [ChartLineData] { get }
    var dates: [Date] { get }
    var xPositions: [CGFloat]  { get }
    var plateData: ChartSelectionData? { get }

    var selectionIndex: Int? { get }
    var visibleIndices: [Int] { get }
    var maxVisibleValue: Int { get }

    func trySelect(x: CGFloat)
    func setLineVisibility(index: Int, visible: Bool)
    func changeLowerBound(newLow: CGFloat)
    func changeUpperBound(newUp: CGFloat)
    func changePoisition(newLow: CGFloat)

    var xUpdateHandler: (() -> Void)? { get set }
    var yUpdateHandler: (() -> Void)? { get set }
    var alphaUpdateHandler: (() -> Void)? { get set }
}

class GraphView: UIView {
    
    private var insetTop: CGFloat = 0
    private var insetBottom: CGFloat = 0
    private var chartBounds: CGRect = .zero

    private var dataSource: GraphDataSourceProtocol
    private var lineWidth: CGFloat
    private var gridVisible: Bool
    private var isMap: Bool
    
    private var charts: [ChartLayerProtocolType]
    private var yGrid: YGridLayerProtocolType
    private var xGrid: XGridLayerProtocolType
    private var selection: SelectionLayerProtocolType
    
    init(dataSource: GraphDataSourceProtocol, lineWidth: CGFloat, isMap: Bool) {
        self.isMap = isMap
        if !isMap {
            insetTop = 8
            insetBottom = 16
        }
        self.gridVisible = !isMap
        self.lineWidth = lineWidth
        self.dataSource = dataSource
        self.charts = [ChartLayerProtocolType]()
        self.yGrid = YGridLayer(step: 40, minVisibleValue: 0, maxVisibleValue: dataSource.maxVisibleValue)
        self.xGrid = XGridLayer()
        self.selection = SelectionLayer()
        super.init(frame: .zero)
        self.layer.addSublayer(xGrid)
        self.layer.addSublayer(yGrid)
        for chart in dataSource.charts {
            let c = LineChartLayer(color: chart.color, lineWidth: lineWidth)
            self.charts.append(c)
            self.layer.addSublayer(c)
        }
        self.layer.addSublayer(selection)
        backgroundColor = .clear
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartBounds = CGRect(x: 0, y: insetTop, width: bounds.width, height: bounds.height - insetTop - insetBottom)
        for l in charts {
            l.frame = chartBounds
            l.resize()
        }
        selection.frame = chartBounds
        yGrid.frame = chartBounds
        yGrid.resize()
        xGrid.frame = CGRect(x: 0, y: bounds.height - insetBottom, width: bounds.width, height: insetBottom)
        xGrid.resize()
    }
    
    func updateChartPositions() {
        guard charts.count > 0 else { return }
        var xPoints = [XGridPoint]()
        for xIndex in dataSource.visibleIndices {
            xPoints.append(XGridPoint(index: xIndex,
                                      x: dataSource.xPositions[xIndex],
                                      value: dataSource.dates[xIndex]))
        }
        let scale = CGFloat(1) / CGFloat(dataSource.maxVisibleValue)
        for cIndex in dataSource.charts.indices {
            var cPoints = [LineChartPoint]()
            for i in dataSource.visibleIndices.indices {
                let xIndex = dataSource.visibleIndices[i]
                let y = dataSource.charts[cIndex].points[xIndex].value
                cPoints.append(LineChartPoint(index: xIndex, x: xPoints[i].x, value: y))
            }
            charts[cIndex].updatePoints(points: cPoints)
            charts[cIndex].updateScale(newScale: scale)
        }
        yGrid.updateMaxVisiblePosition(newMax: dataSource.maxVisibleValue)
        xGrid.updatePoints(points: xPoints)
    }
    
    func updateChartAlpha() {
        for chartIndex in charts.indices {
            charts[chartIndex].updateAlpha(alpha: dataSource.charts[chartIndex].visible ? 1 : 0)
        }
    }
    
    // MARK: Touches, Selection
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    }
}
