//
//  YGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol YGridLayerProtocol: CALayer {
    
    init(step: CGFloat)
    func updateMaxVisiblePosition(newMax: Int)
    func showSelection(x: CGFloat)
    func moveSelection(x: CGFloat)
    func hideSelection()
}

class YGridLayer: CALayer, YGridLayerProtocol, Stylable {
    
    var linePositions = [CGFloat]()
    
    fileprivate var lineShapes = [LineLayer]()
    fileprivate var hidingLineShapes = [LineLayer]()
    private var selectionLineLayer: CAShapeLayer
    
    /// Defines how much must maxValue changed to reset points. 1.05 means 5 percent difference
    var updateThreshold: CGFloat = 1.05
    
    private var step: CGFloat
    private var maxVisibleValue: Int = 0
    
    private lazy var removeHandler: LineLayer.RemoveHandler = { [weak self] lineLayer in
        guard let self = self else { return }
        lineLayer.removeFromSuperlayer()
        self.hidingLineShapes = self.hidingLineShapes.filter { $0.value != lineLayer.value }
    }
    
    required init(step: CGFloat) {
        self.step = step
        selectionLineLayer = CAShapeLayer()
        selectionLineLayer.lineWidth = 1
        super.init()
        addSublayer(selectionLineLayer)
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    override func layoutSublayers() {
        lineShapes.forEach { $0.frame = bounds }
        hidingLineShapes.forEach { $0.frame = bounds }
        calcLinePositions()
        super.layoutSublayers()
        selectionLineLayer.frame = bounds
    }
    
    private func calcLinePositions() {
        var newLinePositions = [CGFloat]()
        var pos: CGFloat = 0
        let stepNorm = step / bounds.height
        while pos < 1.0 {
            newLinePositions.append(pos)
            pos += stepNorm
        }
        self.linePositions = newLinePositions
    }
    
    func updateMaxVisiblePosition(newMax: Int) {
        guard newMax != maxVisibleValue else { return }
        let diff = CGFloat(max(newMax, maxVisibleValue)) / CGFloat(min(newMax, maxVisibleValue))
        if diff > updateThreshold {
            updateLines(newMax: newMax)
            maxVisibleValue = newMax
        }
        updateLinesTargetPositions(forMaxY: newMax)
    }
    
    private func updateLines(newMax: Int) {
        hidingLineShapes += lineShapes
        lineShapes.removeAll()
        for pos in linePositions {
            let value = Int(pos * CGFloat(newMax))
            let y = maxVisibleValue != 0 ? CGFloat(value) / CGFloat(maxVisibleValue) : 0
            let targetY = newMax != 0 ? CGFloat(value) / CGFloat(newMax) : 0
            let lineLayer = LineLayer(value: value, y: y, targetY: targetY, removeHandler: removeHandler)
            
            insertSublayer(lineLayer, below: selectionLineLayer)
            lineShapes.append(lineLayer)
        }
        hidingLineShapes.forEach {
            $0.targetAlpha = 0
        }
    }
    
    private func updateLinesTargetPositions(forMaxY maxY: Int) {
        lineShapes.forEach {
            $0.targetY = maxVisibleValue != 0 ? CGFloat($0.value) / CGFloat(maxY) : 0
        }
        hidingLineShapes.forEach {
            $0.targetY = maxVisibleValue != 0 ? CGFloat($0.value) / CGFloat(maxY) : 0
        }
    }
    
    func showSelection(x: CGFloat) {
        let x = x * bounds.width
        let ptA = CGPoint(x: x, y: 0)
        let ptB = CGPoint(x: x, y: bounds.height)
        let path = UIBezierPath()
        path.move(to: ptA)
        path.addLine(to: ptB)
        selectionLineLayer.path = path.cgPath
        selectionLineLayer.isHidden = false
    }
    
    func moveSelection(x: CGFloat) {
        let x = x * bounds.width
        let ptA = CGPoint(x: x, y: 0)
        let ptB = CGPoint(x: x, y: bounds.height)
        let path = UIBezierPath()
        path.move(to: ptA)
        path.addLine(to: ptB)
        selectionLineLayer.path = path.cgPath
    }
    
    func hideSelection() {
        selectionLineLayer.isHidden = true
    }
    
    func themeDidUpdate(theme: Theme) {
        selectionLineLayer.strokeColor = theme.chartGridMainColor.cgColor
    }
}

private class LineLayer: CALayer, Stylable {
    
    typealias RemoveHandler = (LineLayer) -> Void
    
    private let alphaRemoveThreshold: CGFloat = 0.001
    private let animDuration = 0.1
    
    private var lineLayer: CAShapeLayer
    private var textLayer: CATextLayer
    
    private (set) var value: Int
    
    private var animator = Animator()
    
    var targetY: CGFloat {
        didSet {
            animator.animate(duration: animDuration, update: { [weak self] phase in
                guard let self = self else { return }
                self.y = self.y + (self.targetY - self.y) * phase
                
                let alphaPhase: CGFloat = phase//min(self.y, self.targetY) / max(self.y, self.targetY)
                self.alpha = self.alpha + (self.targetAlpha - self.alpha) * alphaPhase
            })
        }
    }
    var y: CGFloat {
        didSet {
            updateFrame()
        }
    }
    
    var targetAlpha: CGFloat
    var alpha: CGFloat {
        didSet {
            if alpha < alphaRemoveThreshold {
                removeHandler(self)
            }
            opacity = Float(alpha)
        }
    }
    
    var removeHandler: RemoveHandler
    
    required init(value: Int, y: CGFloat, targetY: CGFloat, removeHandler: @escaping RemoveHandler) {
        self.removeHandler = removeHandler
        self.value = value
        self.y = y
        self.targetY = targetY
        lineLayer = CAShapeLayer()
        lineLayer.lineWidth = 1.0
        
        textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 12
        textLayer.string = String(number: value)
        
        alpha = alphaRemoveThreshold
        targetAlpha = 1
        
        super.init()
        startReceivingThemeUpdates()
        addSublayer(lineLayer)
        addSublayer(textLayer)
    }
    
    override init(layer: Any) {
        guard let layer = layer as? LineLayer else { fatalError() }
        self.value = layer.value
        self.y = layer.y
        self.targetY = layer.targetY
        self.alpha = layer.alpha
        self.targetAlpha = layer.targetAlpha
        self.lineLayer = layer.lineLayer
        self.textLayer = layer.textLayer
        self.removeHandler = layer.removeHandler
        super.init(layer: layer)
        
        addSublayer(lineLayer)
        addSublayer(textLayer)
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateFrame()
    }
    
    private func updateFrame() {
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: bounds.width, y: 0))
        
        lineLayer.position = CGPoint(x: 0, y: (CGFloat(1) - y) * bounds.height)
        lineLayer.path = linePath.cgPath
        
        let height: CGFloat = 16
        textLayer.frame = CGRect(x: 0, y: lineLayer.position.y - height, width: bounds.width, height: height)
    }
    
    func themeDidUpdate(theme: Theme) {
        if value == 0 {
            lineLayer.strokeColor = theme.chartGridMainColor.cgColor
        } else {
            lineLayer.strokeColor = theme.chartGridAuxColor.cgColor
        }
        textLayer.foregroundColor = theme.chartTitlesColor.cgColor
    }
}
