//
//  LineChartLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class LineChartLayer: CALayer, ChartLayerProtocol {

    private var shapeLayer: CAShapeLayer
    private weak var dataSource: LineChartDataSource?

    // MARK: - Lifecycle

    required init(source: ChartDataSource, lineWidth: CGFloat) {
        guard let lineSource = source as? LineChartDataSource else { fatalError() }
        self.dataSource = lineSource
        self.shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = source.chart.color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        
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
        
        let path = UIBezierPath()
        for i in dataSource.lo ... dataSource.hi {
            let x = bounds.width * (dataSource.xIndices[i - dataSource.lo] - dataSource.viewport.xLo) / dataSource.viewport.width
            let y = bounds.height - ((CGFloat(dataSource.yValues[i - dataSource.lo].value) - dataSource.viewport.yLo) / dataSource.viewport.height) * bounds.height
            
            let point = CGPoint(x: x, y: y)
            if i == dataSource.lo {
                path.move(to: point)
            } else {
                path.addLine(to: point)
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
