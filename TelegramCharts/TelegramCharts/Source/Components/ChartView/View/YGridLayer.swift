//
//  YGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol YGridLayerProtocol where Self: CALayer {
    
    init(step: CGFloat, maxVisibleValue: Int)
    func redraw()
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
    private var maxVisibleValue: Int
    
    private lazy var removeHandler: LineLayer.RemoveHandler = { [weak self] lineLayer in
        guard let self = self else { return }
        CATransaction.begin()
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.duration = 0.5
        fadeAnim.toValue = 0
        fadeAnim.fromValue = lineLayer.opacity
        lineLayer.add(fadeAnim, forKey: "opacity")
        CATransaction.setCompletionBlock({ [weak self] in
            guard let self = self else { return }
            lineLayer.removeFromSuperlayer()
            self.hidingLineShapes = self.hidingLineShapes.filter { $0.value != lineLayer.value }
        })
        CATransaction.commit()
    }
    
    required init(step: CGFloat, maxVisibleValue: Int) {
        self.step = step
        self.maxVisibleValue = maxVisibleValue
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

    func redraw() {
        updateLines(newMax: maxVisibleValue)
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
        updateLinesPositions(forMaxY: newMax)
    }
    
    private func updateLines(newMax: Int) {
        hidingLineShapes += lineShapes
        lineShapes.removeAll()
        for pos in linePositions {
            let value = Int(pos * CGFloat(newMax))
            let y = maxVisibleValue != 0 ? CGFloat(value) / CGFloat(maxVisibleValue) : 0
            let lineLayer = LineLayer(value: value, y: y, alpha: nil, removeHandler: removeHandler)
            
            insertSublayer(lineLayer, below: selectionLineLayer)
            lineShapes.append(lineLayer)
        }
        hidingLineShapes.forEach {
            $0.targetAlpha = 0
        }
    }
    
    private func updateLinesPositions(forMaxY maxY: Int) {
        lineShapes.forEach {
            $0.y = CGFloat($0.value) / CGFloat(maxY)
        }
        hidingLineShapes.forEach {
            $0.y = CGFloat($0.value) / CGFloat(maxY)
        }
    }

    private func clear() {
        hidingLineShapes.forEach {
            $0.removeFromSuperlayer()
        }
        hidingLineShapes.removeAll()
        lineShapes.forEach {
            $0.removeFromSuperlayer()
        }
        lineShapes.removeAll()
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

    var y: CGFloat {
        didSet {
            updatePosition()
        }
    }
    
    var targetAlpha: CGFloat {
        didSet {
            animator.animate(duration: animDuration, update: { [weak self] phase in
                guard let self = self else { return }
                self.alpha = self.alpha + (self.targetAlpha - self.alpha) * phase
            })
        }
    }
    var alpha: CGFloat {
        didSet {
            if alpha < alphaRemoveThreshold {
                removeHandler(self)
            }
            opacity = Float(alpha)
        }
    }
    
    var removeHandler: RemoveHandler
    
    required init(value: Int, y: CGFloat, alpha: CGFloat?, removeHandler: @escaping RemoveHandler) {
        self.removeHandler = removeHandler
        self.value = value
        self.y = y
        lineLayer = CAShapeLayer()
        lineLayer.lineWidth = 1.0
        
        textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 12
        textLayer.string = String(number: value)
        
        self.alpha = alphaRemoveThreshold
        targetAlpha = 1
        
        super.init()
        if let alpha = alpha {
            self.alpha = alpha
        }
        startReceivingThemeUpdates()
        addSublayer(lineLayer)
        addSublayer(textLayer)
    }
    
    override init(layer: Any) {
        guard let layer = layer as? LineLayer else { fatalError() }
        self.removeHandler = layer.removeHandler
        self.lineLayer = layer.lineLayer
        self.textLayer = layer.textLayer
        self.value = layer.value
        self.y = layer.y
        self.alpha = layer.alpha
        self.targetAlpha = layer.targetAlpha
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
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.width, y: 0))

        lineLayer.frame.size = CGSize(width: bounds.width, height: 1)
        lineLayer.path = linePath.cgPath
        
        let height: CGFloat = 16
        textLayer.frame.size = CGSize(width: bounds.width, height: height)

        updatePosition()
    }

    private func updatePosition() {
        lineLayer.position = CGPoint(x: lineLayer.frame.size.width / 2, y: (CGFloat(1) - y) * bounds.height)
        textLayer.position = CGPoint(x: textLayer.frame.size.width / 2, y: lineLayer.position.y - lineLayer.frame.height / 2 - textLayer.frame.height / 2)
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
