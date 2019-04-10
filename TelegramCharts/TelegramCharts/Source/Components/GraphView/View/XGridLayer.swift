//
//  XGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class XGridPoint {
    var index: Int
    var x: CGFloat
    var value: Date
    
    var visible = true
    
    init(index: Int, x: CGFloat, value: Date) {
        self.index = index
        self.x = x
        self.value = value
    }
}

protocol XGridLayerProtocol where Self: CALayer {
    func updatePoints(points: [XGridPoint])
    func resize()
}

class XGridLayer: CALayer, XGridLayerProtocol {

    private enum RecalcMode {
        case fromLeft
        case fromRight
        case scroll
    }
    
    private let textWidth: CGFloat = 60
    private var maxVisibleCount: Int = 6
    
    private var recalcMode: RecalcMode = .fromRight
    private var step: Int = 1
    
    private var points: [XGridPoint]
    private var titleLayers: [XTextLayer]
    
    override init() {
        points = []
        titleLayers = []
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resize() {
        maxVisibleCount = Int(bounds.width / textWidth)
        updateStep()
        resetLayers()
        updatePositions()
    }
    
    func updatePoints(points: [XGridPoint]) {
        guard points.count > 0 else { return }
        if self.points.count == 0 {
            updateStep()
            resetLayers()
            updatePositions()
            return
        }
        if points.first!.index == self.points.first!.index {
            recalcMode = .fromLeft
        } else if points.last!.index == self.points.last!.index {
            recalcMode = .fromRight
        } else {
            recalcMode = .scroll
        }
        self.points = points
        updateStep()
        resetLayers()
        updatePositions()
    }
    
//    private func
    
    private func resetLayers() {
        titleLayers.forEach { $0.removeFromSuperlayer() }
        titleLayers.removeAll()
        points.forEach { pt in
            guard pt.visible else { return }
            let layer = XTextLayer()
            layer.index = pt.index
            layer.contentsScale = UIScreen.main.scale
            layer.fontSize = 12
            layer.string = pt.value.string(format: .monthDay)
            layer.frame = CGRect(x: 0, y: 0, width: textWidth, height: 14)
            addSublayer(layer)
            titleLayers.append(layer)
        }
//        if let lo = points.first(where: { $0.visible }),
//            let hi = points.last(where: { $0.visible }) {
//
//        }
    }
    
    private func updatePositions() {
        titleLayers.forEach { l in
            guard let x = points.first(where: { $0.index == l.index })?.x else {
                l.removeFromSuperlayer()
                return
            }
            l.position.x = x * bounds.width
        }
    }
    
    private func updateStep() {
        let visibleWidth = textWidth * CGFloat(maxVisibleCount)
        points.forEach { pt in
            pt.visible = true
        }
    }
    
    func themeDidUpdate(theme: Theme) {
    }
}

fileprivate class XTextLayer: CATextLayer {
    var index: Int!
}
