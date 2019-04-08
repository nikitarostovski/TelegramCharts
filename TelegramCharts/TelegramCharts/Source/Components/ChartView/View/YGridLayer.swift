//
//  YGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol YGridLayerProtocol where Self: CALayer {
    
    init(step: CGFloat, minVisibleValue: Int, maxVisibleValue: Int)
    func redraw()
    func updateMaxVisiblePosition(newMax: Int)
    func showSelection(x: CGFloat)
    func moveSelection(x: CGFloat)
    func hideSelection()
}

class YGridLayer: CALayer, YGridLayerProtocol, Stylable {
    
    var linePositions = [CGFloat]()
    
//    fileprivate var lineShapes = [LineLayer]()
    private var selectionLineLayer: CAShapeLayer
    
    /// Defines how much must maxValue changed to reset points. 1.05 means 5 percent difference
    var updateThreshold: CGFloat = 1.025
    
    private var step: CGFloat
    private var maxVisibleValue: Int
    private var minVisibleValue: Int
    
    private lazy var removeHandler: LineLayer.RemoveHandler = { [weak self] lineLayer in
        guard let self = self else { return }
        let a = Animator()
        a.animate(duration: 0.1, easing: .linear, update: { [weak self] phase in
            lineLayer.opacity = lineLayer.opacity * Float(1.0 - phase)
        }, finish: {  [weak self] in
            guard let self = self else { return }
            lineLayer.removeFromSuperlayer()
        })
    }
    
    required init(step: CGFloat, minVisibleValue: Int, maxVisibleValue: Int) {
        self.step = step
        self.minVisibleValue = minVisibleValue
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
        calcLinePositions()
        updateLines()
        sublayers?.forEach {
            guard let l = $0 as? LineLayer else { return }
            l.frame = bounds
            l.resize()
        }
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
        maxVisibleValue = newMax
        if diff > updateThreshold {
            updateLines()
        }
        updateLinesPositions()
    }
    
    private func updateLines() {
        sublayers?.forEach {
            guard let l = $0 as? LineLayer else { return }
            if !l.isRemoving {
                l.remove()
            }
        }
        for pos in linePositions {
            let value = Int(pos * CGFloat(maxVisibleValue))
            let lineLayer = LineLayer(value: value, maxValue: maxVisibleValue, removeHandler: removeHandler)
            lineLayer.frame = bounds
            lineLayer.resize()
            insertSublayer(lineLayer, below: selectionLineLayer)
        }
    }
    
    private func updateLinesPositions() {
        sublayers?.forEach {
            guard let l = $0 as? LineLayer else { return }
            l.maxValue = maxVisibleValue != 0 ? maxVisibleValue : 0
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
    
    private var lineLayer: CAShapeLayer
    private var textLayer: CATextLayer
    
    private (set) var value: Int
    var maxValue: Int {
        didSet {
            updatePosition()
        }
    }
    private (set) var isRemoving = false
    var removed = false
    var removeHandler: RemoveHandler
    
    required init(value: Int, maxValue: Int, removeHandler: @escaping RemoveHandler) {
        self.removeHandler = removeHandler
        self.value = value
        self.maxValue = maxValue
        lineLayer = CAShapeLayer()
        lineLayer.lineWidth = 1.0
        
        textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 12
        textLayer.string = String(number: value)
        
        super.init()
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
        self.maxValue = layer.maxValue
        super.init(layer: layer)
        
        addSublayer(lineLayer)
        addSublayer(textLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    func remove() {
        isRemoving = true
        removeHandler(self)
    }
    
    func resize() {
        updateFrame()
    }
    
    private func updateFrame() {
        let height: CGFloat = 16
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: bounds.width, y: 0))
        lineLayer.path = linePath.cgPath
        
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        lineLayer.frame.size = CGSize(width: bounds.width, height: 1)
        textLayer.frame.size = CGSize(width: bounds.width, height: height)
        CATransaction.commit()
        updatePosition()
    }

    private func updatePosition() {
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        let y = CGFloat(value) / CGFloat(maxValue)
        lineLayer.position = CGPoint(x: lineLayer.frame.size.width / 2, y: (CGFloat(1) - y) * bounds.height)
        textLayer.position = CGPoint(x: textLayer.frame.size.width / 2, y: lineLayer.position.y - lineLayer.frame.height / 2 - textLayer.frame.height / 2)
        CATransaction.commit()
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
