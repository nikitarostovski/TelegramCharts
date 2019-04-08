//
//  ChartComplexView.swift
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

protocol ChartDataSourceProtocol {

    var range: ClosedRange<CGFloat> { get }

    var lines: [ChartLineData] { get }
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

class ChartComplexView: UIView {
    
    private var insetTop: CGFloat = 0
    private var insetBottom: CGFloat = 0
    private var chartBounds: CGRect = .zero

    private var dataSource: ChartDataSourceProtocol
    private var lineWidth: CGFloat
    private var gridVisible: Bool
    private var isMap: Bool
    
    private var chartLines: [ChartLayerProtocolType]
    private var yGrid: YGridLayerProtocolType
    private var xGrid: XGridLayerProtocolType
    private var selection: SelectionLayerProtocolType
    
    init(dataSource: ChartDataSourceProtocol, lineWidth: CGFloat, isMap: Bool) {
        self.isMap = isMap
        if isMap {
            insetTop = 8
            insetBottom = 16
        }
        self.gridVisible = !isMap
        self.lineWidth = lineWidth
        self.dataSource = dataSource
        self.chartLines = [ChartLayerProtocolType]()
        self.yGrid = YGridLayer(step: 40, minVisibleValue: 0, maxVisibleValue: dataSource.maxVisibleValue)
        self.xGrid = XGridLayer()
        self.selection = SelectionLayer()
        super.init(frame: .zero)
        self.layer.addSublayer(xGrid)
        self.layer.addSublayer(yGrid)
        for line in dataSource.lines {
            let l = LineChartLayer(color: line.color, lineWidth: lineWidth)
            self.chartLines.append(l)
            self.layer.addSublayer(l)
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
        for l in chartLines {
            l.frame = chartBounds
            l.redraw()
        }
        selection.frame = chartBounds
        yGrid.frame = chartBounds
        yGrid.redraw()
        xGrid.frame = CGRect(x: 0, y: bounds.height - insetBottom, width: bounds.width, height: insetBottom)
    }
    
    func updateChartPositions() {
        guard chartLines.count > 0 else { return }
        var xPos = [CGFloat]()
        var dates = [Date]()
        for xIndex in dataSource.visibleIndices {
            xPos.append(dataSource.xPositions[xIndex])
            dates.append(dataSource.dates[xIndex])
        }
        let scale = CGFloat(1) / CGFloat(dataSource.maxVisibleValue)
        for lineIndex in dataSource.lines.indices {
            var linePoints = [LineChartPoint]()
            for i in dataSource.visibleIndices.indices {
                let xIndex = dataSource.visibleIndices[i]
                let y = dataSource.lines[lineIndex].points[xIndex].value
                linePoints.append(LineChartPoint(index: xIndex, x: xPos[i], value: y))
            }
            chartLines[lineIndex].updatePoints(points: linePoints)
            chartLines[lineIndex].updateScale(newScale: scale)
            chartLines[lineIndex].redraw()
        }
        yGrid.updateMaxVisiblePosition(newMax: dataSource.maxVisibleValue)
        xGrid.updatePoints(xPos: xPos, dates: dates)
    }
    
    func updateChartAlpha() {
        for lineIndex in chartLines.indices {
            chartLines[lineIndex].updateAlpha(alpha: dataSource.lines[lineIndex].visible ? 1 : 0)
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
        for line in chartLines {
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
        for line in chartLines {
            line.moveSelection(index: index)
        }
    }
    
    private func hideSelection() {
        selection.hide()
        yGrid.hideSelection()
        for line in chartLines {
            line.hideSelection()
        }
    }
}
