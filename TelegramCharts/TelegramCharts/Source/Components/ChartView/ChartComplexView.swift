//
//  ChartComplexView.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol ChartDataSource {
    var visibleIndices: [Int] { get }
    var yDrawAxis: ChartDrawAxisY { get }
    var xDrawAxis: ChartDrawAxisX { get }
    var drawLines: [ChartDrawLine] { get }
    var range: ClosedRange<CGFloat> { get }
    var maxVisibleValue: Int { get }
    var maxVisibleY: CGFloat { get }
    var maxTotalVisibleY: CGFloat { get }
    
    var gridMainColor: UIColor { get }
    var gridAuxColor: UIColor { get }
    var backColor: UIColor { get }
    
    var plateData: SelectionData? { get }
    
    func viewSizeChanged(newSize: CGSize)
}

class ChartComplexView: UIView {
    
    private let insetTop: CGFloat = 0
    private let insetBottom: CGFloat = 0
    private var chartBounds: CGRect = .zero

    private var dataSource: ChartDataSource
    private var lineWidth: CGFloat
    private var gridVisible: Bool
    private var isMap: Bool
    
    private var chartLines: [ChartLayerProtocol]
    private var yGrid: YGridLayerProtocol
    private var xGrid: XGridLayerProtocol
    private var selection: SelectionLayerProtocol
    
    init(dataSource: ChartDataSource, lineWidth: CGFloat, isMap: Bool) {
        self.isMap = isMap
        self.gridVisible = !isMap
        self.lineWidth = lineWidth
        self.dataSource = dataSource
        self.chartLines = [ChartLayerProtocol]()
        self.yGrid = YGridLayer(step: 40)
        self.xGrid = XGridLayer()
        self.selection = SelectionLayer(style: .lineChart)
        
        super.init(frame: .zero)
        self.layer.addSublayer(xGrid)
        self.layer.addSublayer(yGrid)
        for line in dataSource.drawLines {
            let layer = LineChartLayer(color: line.color, lineWidth: lineWidth)
            self.chartLines.append(layer)
            self.layer.addSublayer(layer)
        }
        self.layer.addSublayer(selection)
        backgroundColor = .clear
        layer.masksToBounds = true
        
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartBounds = CGRect(x: 0, y: insetTop, width: bounds.width, height: bounds.height - insetTop - insetBottom)
        for layer in chartLines {
            layer.frame = chartBounds
        }
        selection.frame = chartBounds
        yGrid.frame = chartBounds
        xGrid.frame = CGRect(x: 0, y: bounds.height - insetBottom, width: bounds.width, height: insetBottom)
    }
    
    func updateChartPositions() {
        guard chartLines.count > 0 else { return }
        var xPos = [CGFloat]()
        var dates = [Date]()
        for xIndex in dataSource.visibleIndices {
            let scaleX = chartLines.first!.frame.size.width
            let x = dataSource.xDrawAxis.points[xIndex].x * scaleX
            xPos.append(x)
            dates.append(dataSource.xDrawAxis.points[xIndex].value)
        }
        for lineIndex in chartLines.indices {
            var yVal = [Int]()
            for xIndex in dataSource.visibleIndices {
                let y = dataSource.drawLines[lineIndex].points[xIndex].value
                yVal.append(y)
            }
            chartLines[lineIndex].updatePoints(xPos: xPos, yVal: yVal)
            chartLines[lineIndex].updateMaxValue(maxValue: dataSource.maxVisibleValue)
        }
        
        yGrid.updateMaxVisiblePosition(newMax: dataSource.maxVisibleValue)
        xGrid.updatePoints(xPos: xPos, dates: dates)
    }
    
    func updateChartAlpha() {
        for lineIndex in chartLines.indices {
            chartLines[lineIndex].updateAlpha(alpha: dataSource.drawLines[lineIndex].alpha)
        }
    }
    
    @objc private func tap(gr: UITapGestureRecognizer) {
        let pos = gr.location(in: self)
        guard chartBounds.contains(pos) else {
            selection.hide()
            return
        }
        let x = (pos.x - chartBounds.origin.x) / chartBounds.size.width
        let index = dataSource.xDrawAxis.getClosestIndex(position: x)
        dataSource.xDrawAxis.selectionIndex = index
        guard let data = dataSource.plateData else {
            selection.hide()
            return
        }
        selection.setData(data: data)
        selection.show(x: x)
    }
}
