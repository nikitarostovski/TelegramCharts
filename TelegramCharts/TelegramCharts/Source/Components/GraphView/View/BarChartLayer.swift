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
    private weak var dataSource: ChartDataSource?

    // MARK: - Lifecycle

    required init(source: ChartDataSource, lineWidth: CGFloat) {
        self.dataSource = source
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
            bounds != .zero
        else {
            return
        }
        let lastIndex = dataSource.chart.values.count - 1
        
        var lo = Int(dataSource.viewport.xLo * CGFloat(lastIndex) - 0.5)
        var hi = Int(dataSource.viewport.xHi * CGFloat(lastIndex) + 0.5)
        lo = max(lo, 0)
        hi = min(hi, lastIndex)
        
        let columnWidth = CGFloat(1) / dataSource.viewport.width
        
        let path = UIBezierPath()
        for i in lo ... hi {
            let xNorm = CGFloat(i) / CGFloat(dataSource.chart.values.count - 1)
            let x = bounds.width * (xNorm - dataSource.viewport.xLo) / dataSource.viewport.width
            
            let y = bounds.height - ((CGFloat(dataSource.chart.values[i]) - dataSource.viewport.yLo) / dataSource.viewport.height) * bounds.height
            let pointLeft = CGPoint(x: x - columnWidth / 2, y: y)
            let pointRight = CGPoint(x: x + columnWidth / 2, y: y)
            if i == lo {
                path.move(to: CGPoint(x: pointLeft.x, y: bounds.height))
            }
            path.addLine(to: pointLeft)
            path.addLine(to: pointRight)
            if i == hi {
                path.addLine(to: CGPoint(x: pointRight.x, y: bounds.height))
            }
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
