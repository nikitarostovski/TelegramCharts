//
//  AreaChartLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class AreaChartLayer: CALayer, ChartLayerProtocol {

    private var shapeLayer: CAShapeLayer
    private weak var dataSource: AreaChartDataSource?

    // MARK: - Lifecycle

    required init(source: ChartDataSource, lineWidth: CGFloat) {
        guard let areaSource = source as? AreaChartDataSource else { fatalError() }
        self.dataSource = areaSource
        self.shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = source.chart.color.cgColor
        
        super.init()
        masksToBounds = false
        addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ChartLayerProtocol
    
    func update() {
        guard let dataSource = dataSource,
            dataSource.viewport.width > 0,
            dataSource.viewport.height > 0,
            bounds != .zero
            else {
                return
        }
        let columnWidth = bounds.width / CGFloat(dataSource.hi - dataSource.lo)
        var lastXRight: CGFloat? = nil
        
        let path = CGMutablePath()
        var yLoLast: CGFloat? = nil
        var yHiLast: CGFloat? = nil
        for i in dataSource.lo ... dataSource.hi {
            let x = bounds.width * (dataSource.xIndices[i - dataSource.lo] - dataSource.viewport.xLo) / dataSource.viewport.width
            let yLo = bounds.height - ((CGFloat(dataSource.yValues[i - dataSource.lo].offset) / CGFloat(dataSource.yValues[i - dataSource.lo].sumValue) - dataSource.viewport.yLo) / dataSource.viewport.height) * bounds.height
            let yHi = bounds.height - ((CGFloat(dataSource.yValues[i - dataSource.lo].offset + dataSource.yValues[i - dataSource.lo].value) / CGFloat(dataSource.yValues[i - dataSource.lo].sumValue) - dataSource.viewport.yLo) / dataSource.viewport.height) * bounds.height
            
            if let yLoLast = yLoLast, let yHiLast = yHiLast {
                
                var xLeft: CGFloat
                if let lastXRight = lastXRight {
                    xLeft = lastXRight
                } else {
                    xLeft = x - columnWidth
                }
                let xRight: CGFloat = x + columnWidth
                lastXRight = xRight
                
                let pointBottomLeft = CGPoint(x: xLeft, y: yLoLast)
                let pointBottomRight = CGPoint(x: xRight, y: yLo)
                let pointTopLeft = CGPoint(x: xLeft, y: yHiLast)
                let pointTopRight = CGPoint(x: xRight, y: yHi)
                
                path.move(to: pointTopLeft)
                path.addLine(to: pointTopRight)
                path.addLine(to: pointBottomRight)
                path.addLine(to: pointBottomLeft)
            }
            yLoLast = yLo
            yHiLast = yHi
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
