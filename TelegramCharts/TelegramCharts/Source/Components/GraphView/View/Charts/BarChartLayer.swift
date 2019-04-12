//
//  BarChartLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class BarChartLayer: CALayer, ChartLayerProtocol {

    private var shapeLayer: CAShapeLayer
    private weak var dataSource: BarChartDataSource?

    // MARK: - Lifecycle

    required init(source: ChartDataSource, lineWidth: CGFloat) {
        guard let barSource = source as? BarChartDataSource else { fatalError() }
        self.dataSource = barSource
        self.shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = source.chart.color.cgColor
        
        super.init()
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
        let columnWidth = bounds.width / CGFloat(dataSource.hi - dataSource.lo) + 1
        
        let path = UIBezierPath()
        for i in dataSource.lo ... dataSource.hi {
            let x = bounds.width * (dataSource.xIndices[i - dataSource.lo] - dataSource.viewport.xLo) / dataSource.viewport.width
            let yLo = bounds.height - ((CGFloat(dataSource.yValues[i - dataSource.lo].offset) - dataSource.viewport.yLo) / dataSource.viewport.height) * bounds.height
            let yHi = bounds.height - ((CGFloat(dataSource.yValues[i - dataSource.lo].offset + dataSource.yValues[i - dataSource.lo].value) - dataSource.viewport.yLo) / dataSource.viewport.height) * bounds.height
            
            let pointBottomLeft = CGPoint(x: x - columnWidth / 2, y: yLo)
            let pointBottomRight = CGPoint(x: x + columnWidth / 2, y: yLo)
            let pointTopLeft = CGPoint(x: x - columnWidth / 2, y: yHi)
            let pointTopRight = CGPoint(x: x + columnWidth / 2, y: yHi)
            
            path.move(to: pointTopLeft)
            path.addLine(to: pointTopRight)
            path.addLine(to: pointBottomRight)
            path.addLine(to: pointBottomLeft)
            
        }
        shapeLayer.path = path.cgPath
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
