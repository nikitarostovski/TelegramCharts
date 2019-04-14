//
//  GraphView.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    private static let metalEnabled = false
    
    var insets: UIEdgeInsets = .zero
    private var chartBounds: CGRect = .zero
    private var textWidth: CGFloat
    
    private weak var dataSource: GraphDataSource?
    private var lineWidth: CGFloat
    private var isMap: Bool
    
    private var xTintView: TintView?
    
    private var selectionView: SelectionView?
    
    private var charts: ChartViewProtocol
    private var yGrids: [YGridLayer]
    private var yTitles: [YTextLayer]
    private var xGrid: XGridLayer?
    private var xTitles: XTextLayer?
    
    init(dataSource: GraphDataSource, lineWidth: CGFloat, insets: UIEdgeInsets, isMap: Bool, textWidth: CGFloat) {
        self.textWidth = textWidth
        self.isMap = isMap
        self.lineWidth = lineWidth
        self.dataSource = dataSource
        if GraphView.metalEnabled {
            self.charts = MetalChartsView(dataSource: dataSource, isMap: isMap, lineWidth: lineWidth)
        } else {
            self.charts = ChartsView(dataSource: dataSource, isMap: isMap, lineWidth: lineWidth)
        }
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
            self.selectionView = SelectionView()
        }
        
        super.init(frame: .zero)
        if dataSource.chartDataSources.first?.chart.type != .line {
            addSubview(charts as! UIView)
        }
        yGrids.forEach { layer.addSublayer($0) }
        if dataSource.chartDataSources.first?.chart.type == .line {
            addSubview(charts as! UIView)
        }
        yTitles.forEach { layer.addSublayer($0) }
        if let xTitles = xTitles {
            layer.addSublayer(xTitles)
        }
        if let xGrid = xGrid {
            layer.addSublayer(xGrid)
        }
        if let xTintView = xTintView {
            addSubview(xTintView)
        }
        if let selectionView = selectionView {
            addSubview(selectionView)
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
        (charts as! UIView).frame = chartBounds
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
        charts.update()
        yGrids.forEach { $0.updatePositions() }
        yTitles.forEach { $0.updatePositions() }
        xTitles?.updatePositions()
        
        if let selectionView = selectionView, let dataSource = dataSource, let chart = dataSource.chartDataSources.first {
            if let index = chart.selectedIndex {
                var x = chartBounds.minX + (chart.xIndices[index] - chart.viewport.xLo) / chart.viewport.width * chartBounds.width
                selectionView.update(index: index, dataSource: dataSource, animated: !selectionView.isHidden)
                if x > bounds.width / 2 {
                    x -= selectionView.frame.width / 2 + 8 + charts.barWidth / 2
                } else {
                    x += selectionView.frame.width / 2 + 8 + charts.barWidth / 2
                }
                if selectionView.isHidden {
                    selectionView.center.x = x
                } else {
                    UIView.animate(withDuration: 0.05) {
                        selectionView.center.x = x
                    }
                }
                selectionView.isHidden = false
                UIView.animate(withDuration: 0.05, animations: {
                    self.selectionView?.alpha = 1
                })
                selectionView.frame.origin.y = chartBounds.origin.y + 8
            } else {
                UIView.animate(withDuration: 0.05, animations: {
                    self.selectionView?.alpha = 0
                }) { (_) in
                    self.selectionView?.isHidden = true
                }
            }
        } else {
            UIView.animate(withDuration: 0.05, animations: {
                self.selectionView?.alpha = 0
            }) { (_) in
                self.selectionView?.isHidden = true
            }
        }
    }
    
    func resetGridValues() {
        guard bounds != .zero else { return }
        yGrids.forEach { $0.resetValues() }
        yTitles.forEach { $0.resetValues() }
    }
    
    func updateChartAlpha() {
        /*for chartIndex in charts.indices {
            charts[chartIndex].updateAlpha(alpha: dataSource.charts[chartIndex].visible ? 1 : 0)
        }*/
    }
    
    // MARK: Touches, Selection
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let pos = touches.first!.location(in: self)
        guard chartBounds.contains(pos), !(selectionView?.frame.contains(pos) == true && selectionView?.isHidden == false) else {
            dataSource?.deselect()
            return
        }
        let x = (pos.x - chartBounds.origin.x) / chartBounds.size.width
        dataSource?.trySelect(x: x)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let pos = touches.first!.location(in: self)
        guard chartBounds.contains(pos) else {
            return
        }
        let x = (pos.x - chartBounds.origin.x) / chartBounds.size.width
        dataSource?.trySelect(x: x)
    }
}
