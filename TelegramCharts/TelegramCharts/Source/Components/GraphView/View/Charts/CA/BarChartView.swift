//
//  BarChartView.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class BarChartView: UIView, ChartViewProtocol {

    private (set) var barWidth: CGFloat
    
    private var isMap: Bool
    private var shapeLayer: CAShapeLayer
    private var selectionLayer: CAShapeLayer
    private weak var dataSource: BarChartDataSource?

    // MARK: - Lifecycle

    required init(source: ChartDataSource, lineWidth: CGFloat, isMap: Bool) {
        guard let barSource = source as? BarChartDataSource else { fatalError() }
        self.barWidth = 0
        self.isMap = isMap
        self.dataSource = barSource
        self.shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = source.chart.color.cgColor
        
        self.selectionLayer = CAShapeLayer()
        selectionLayer.strokeColor = UIColor.clear.cgColor
        selectionLayer.fillColor = source.chart.color.cgColor
        
        super.init(frame: .zero)
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.addSublayer(shapeLayer)
        layer.addSublayer(selectionLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ChartViewProtocol
    
    func update() {
        guard let dataSource = dataSource,
            dataSource.xIndices.count > 1,
            bounds != .zero
            else {
                return
        }
        let startIndex: Int
        let finishIndex: Int
        let viewport: Viewport
        if isMap {
            viewport = dataSource.mapViewport
            startIndex = 0
            finishIndex = dataSource.yValues.count - 1
        } else {
            viewport = dataSource.viewport
            startIndex = dataSource.loVis
            finishIndex = dataSource.hiVis
        }
        guard viewport.width > 0,
            viewport.height > 0
        else {
            return
        }
        
        let distance = dataSource.xIndices[1] - dataSource.xIndices[0]
        barWidth = bounds.width * distance / viewport.width
        var lastXRight: CGFloat? = nil
        
        let selectionPath = CGMutablePath()
        var selectionVisible = false
        let path = CGMutablePath()
        for i in startIndex ... finishIndex {
            let x = bounds.width * (dataSource.xIndices[i] - viewport.xLo) / viewport.width
            let yLo = bounds.height - ((CGFloat(dataSource.yValues[i].offset) - viewport.yLo) / viewport.height) * bounds.height
            let yHi = bounds.height - ((CGFloat(dataSource.yValues[i].offset + dataSource.yValues[i].value) - viewport.yLo) / viewport.height) * bounds.height
            
            var xLeft: CGFloat
            if let lastXRight = lastXRight {
                xLeft = lastXRight
            } else {
                xLeft = x
            }
            let xRight: CGFloat = x + barWidth
            lastXRight = xRight
            
            let pointBottomLeft = CGPoint(x: xLeft, y: yLo)
            let pointBottomRight = CGPoint(x: xRight, y: yLo)
            let pointTopLeft = CGPoint(x: xLeft, y: yHi)
            let pointTopRight = CGPoint(x: xRight, y: yHi)
            
            path.move(to: pointTopLeft)
            path.addLine(to: pointTopRight)
            path.addLine(to: pointBottomRight)
            path.addLine(to: pointBottomLeft)
            
            if i == dataSource.selectedIndex && !isMap {
                selectionVisible = true
                selectionPath.move(to: pointTopLeft)
                selectionPath.addLine(to: pointTopRight)
                selectionPath.addLine(to: pointBottomRight)
                selectionPath.addLine(to: pointBottomLeft)
                selectionLayer.path = selectionPath
            }
        }
        if selectionVisible {
            selectionLayer.isHidden = false
            shapeLayer.opacity = 0.5
        } else {
            selectionLayer.isHidden = true
            shapeLayer.opacity = 1
        }
        shapeLayer.path = path
    }
}

// MARK: Selection

/*extension LineChartLayer {

    func updateSelectionPosition(index: Int) {
        guard let scale = scale else { return }
        guard let p = points.first(where: { $0.index == index }) else { return }
        let y = CGFloat(p.value) * scale * bounds.height
        selectionLayer.position = CGPoint(x: p.x, y: bounds.height - y)
    }

    func select(index: Int) {
        let r = selectionTargetRadius
        let rect = CGRect(x: 0, y: 0, width: 2 * r, height: 2 * r)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: r)
        selectionLayer.path = path.cgPath
        updateSelectionPosition(index: index)
    }

    func moveSelection(index: Int) {
        updateSelectionPosition(index: index)
    }

    func hideSelection() {
        selectionLayer.path = nil
    }
}*/
