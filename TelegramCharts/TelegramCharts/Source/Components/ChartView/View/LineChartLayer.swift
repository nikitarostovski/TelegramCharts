//
//  LineChartLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol ChartLayerProtocol where Self: CALayer {
    
    init(color: UIColor, lineWidth: CGFloat)
    func updatePoints(points: [LineChartPoint])
    func updateScale(newScale: CGFloat)
    func updateAlpha(alpha: CGFloat)

    func redraw()
    
    func select(index: Int)
    func moveSelection(index: Int)
    func hideSelection()
}

struct LineChartPoint {
    var index: Int
    var x: CGFloat
    var value: Int
}

class LineChartLayer: CALayer, ChartLayerProtocol {

    private var selectionTargetRadius: CGFloat

    private var color: UIColor
    private var shapeLayer: CAShapeLayer
    private var selectionLayer: CAShapeLayer

    private var scale: CGFloat?
    private var points = [LineChartPoint]()

    // MARK: - Lifecycle

    required init(color: UIColor, lineWidth: CGFloat) {
        self.selectionTargetRadius = lineWidth * 4
        self.color = color
        self.shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.fillColor = UIColor.clear.cgColor

        selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.clear.cgColor
        selectionLayer.strokeColor = color.cgColor
        selectionLayer.lineWidth = lineWidth
        
        super.init()
        addSublayer(shapeLayer)
        addSublayer(selectionLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ChartLayerProtocol

    func redraw() {
        recalcPoints()
    }
    
    func updatePoints(points: [LineChartPoint]) {
        self.points = points
    }
    
    func updateScale(newScale: CGFloat) {
        self.scale = newScale
        redraw()
    }
    
    func updateAlpha(alpha: CGFloat) {
        shapeLayer.opacity = Float(alpha)
    }
    
    private func recalcPoints() {
        guard let scale = scale else { return }
        guard bounds.size != .zero else { return }
        let path = UIBezierPath()
        for i in points.indices {
            let p = points[i]
            let y = CGFloat(p.value) * scale * bounds.height
            let point = CGPoint(x: p.x * bounds.width, y: bounds.height - y)
            if i == 0 {
                path.move(to: point)
                continue
            }
            path.addLine(to: point)
        }
        shapeLayer.path = path.cgPath
    }
}

// MARK: Selection

extension LineChartLayer {

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
}
