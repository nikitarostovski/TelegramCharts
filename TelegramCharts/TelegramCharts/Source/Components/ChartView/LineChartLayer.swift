//
//  LineChartLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol ChartLayerProtocol: CALayer {
    
    init(color: UIColor, lineWidth: CGFloat)
    func updatePoints(xPos: [CGFloat], yVal: [Int])
    func updateMaxValue(maxValue: Int)
    func updateAlpha(alpha: CGFloat)
}

class LineChartLayer: CALayer, ChartLayerProtocol {
    
    private var color: UIColor
    private var shapeLayer: CAShapeLayer
    
    private var maxVisibleValue: CGFloat = 0
    private var xPositions = [CGFloat]()
    private var yValues = [Int]()
    
    private var animator = Animator()
    
    required init(color: UIColor, lineWidth: CGFloat) {
        self.color = color
        self.shapeLayer = CAShapeLayer()
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
    
    func updatePoints(xPos: [CGFloat], yVal: [Int]) {
        self.xPositions = xPos
        self.yValues = yVal
        recalcPoints()
    }
    
    func updateMaxValue(maxValue: Int) {
        animator.animate(duration: 0.5, update: { [weak self] (phase) in
            guard let self = self else { return }
            self.maxVisibleValue = self.maxVisibleValue + (CGFloat(maxValue) - self.maxVisibleValue) * phase
            self.recalcPoints()
        })
    }
    
    func updateAlpha(alpha: CGFloat) {
        shapeLayer.strokeColor = color.withAlphaComponent(alpha).cgColor
    }
    
    private func recalcPoints() {
        let path = UIBezierPath()
        for i in xPositions.indices {
            let y = maxVisibleValue != 0 ? CGFloat(yValues[i]) / maxVisibleValue * bounds.height : 0
            let point = CGPoint(x: xPositions[i], y: bounds.height - y)
            if i == 0 {
                path.move(to: point)
                continue
            }
            path.addLine(to: point)
        }
        shapeLayer.path = path.cgPath
    }
}
