//
//  LineChartLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class LineChartLayer: CALayer, ChartLayerProtocol {

    private var isMap: Bool
    private var shapeLayer: CAShapeLayer
    private weak var dataSource: LineChartDataSource?

    // MARK: - Lifecycle

    required init(source: ChartDataSource, lineWidth: CGFloat, isMap: Bool) {
        guard let lineSource = source as? LineChartDataSource else { fatalError() }
        self.isMap = isMap
        self.dataSource = lineSource
        self.shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = source.chart.color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        
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
        
        let path = CGMutablePath()
        for i in startIndex ... finishIndex {
            let x = bounds.width * (dataSource.xIndices[i] - viewport.xLo) / viewport.width
            let y = bounds.height - ((CGFloat(dataSource.yValues[i].value) - viewport.yLo) / viewport.height) * bounds.height
            
            let point = CGPoint(x: x, y: y)
            if i == startIndex {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
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
