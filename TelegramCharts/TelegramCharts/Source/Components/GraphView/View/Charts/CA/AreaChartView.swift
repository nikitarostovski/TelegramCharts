//
//  AreaChartView.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class AreaChartView: UIView, ChartViewProtocol {

    private (set) var barWidth: CGFloat = 0
    
    private var isMap: Bool
    private var shapeLayer: CAShapeLayer
    private weak var dataSource: AreaChartDataSource?

    // MARK: - Lifecycle

    required init(source: ChartDataSource, lineWidth: CGFloat, isMap: Bool) {
        guard let areaSource = source as? AreaChartDataSource else { fatalError() }
        self.isMap = isMap
        self.dataSource = areaSource
        self.shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = source.chart.color.cgColor
        
        super.init(frame: .zero)
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.addSublayer(shapeLayer)
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
        let columnWidth = bounds.width * distance
        var lastXRight: CGFloat? = nil
        
        let path = CGMutablePath()
        var yLoLast: CGFloat? = nil
        var yHiLast: CGFloat? = nil
        for i in startIndex ... finishIndex {
            let x = bounds.width * (dataSource.xIndices[i] - viewport.xLo) / viewport.width
            let yLo = bounds.height - ((CGFloat(dataSource.yValues[i].offset) / CGFloat(dataSource.yValues[i].sumValue) - viewport.yLo) / viewport.height) * bounds.height
            let yHi = bounds.height - ((CGFloat(dataSource.yValues[i].offset + dataSource.yValues[i].value) / CGFloat(dataSource.yValues[i].sumValue) - viewport.yLo) / viewport.height) * bounds.height
            
            if let yLoLast = yLoLast, let yHiLast = yHiLast {
                var xLeft: CGFloat
                if let lastXRight = lastXRight {
                    xLeft = lastXRight
                } else {
                    xLeft = x - columnWidth
                }
                let xRight: CGFloat = x
                
                let pointBottomLeft = CGPoint(x: xLeft, y: yLoLast + 0.25)
                let pointBottomRight = CGPoint(x: xRight, y: yLo + 0.25)
                let pointTopLeft = CGPoint(x: xLeft, y: yHiLast - 0.25)
                let pointTopRight = CGPoint(x: xRight, y: yHi - 0.25)
                
                path.move(to: pointTopLeft)
                path.addLine(to: pointTopRight)
                path.addLine(to: pointBottomRight)
                path.addLine(to: pointBottomLeft)
            }
            lastXRight = x
            yLoLast = yLo
            yHiLast = yHi
        }
        shapeLayer.path = path
        shapeLayer.opacity = Float(dataSource.opacity)
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
