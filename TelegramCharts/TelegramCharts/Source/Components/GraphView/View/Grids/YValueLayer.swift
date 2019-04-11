//
//  YValueLayer.swift
//  TelegramCharts
//
//  Created by Rost on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YValueLayer: CALayer {
    
    var lineLayer: CAShapeLayer
    var leftTextLayer: CATextLayer?
    var rightTextLayer: CATextLayer?
    
    private weak var source: YValueData?
    
    init(source: YValueData) {
        self.source = source
        lineLayer = CAShapeLayer()
        lineLayer.lineWidth = 1
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        lineLayer.fillColor = UIColor.clear.cgColor
        
        if let textLeft = source.textLeft {
            leftTextLayer = CATextLayer()
            leftTextLayer!.contentsScale = UIScreen.main.scale
            leftTextLayer!.fontSize = 12
            leftTextLayer!.alignmentMode = .left
            leftTextLayer!.string = textLeft
        }
        
        if let textRight = source.textRight {
            rightTextLayer = CATextLayer()
            rightTextLayer!.contentsScale = UIScreen.main.scale
            rightTextLayer!.fontSize = 12
            rightTextLayer!.alignmentMode = .right
            rightTextLayer!.string = textRight
        }
        
        super.init()
        addSublayer(lineLayer)
        if leftTextLayer != nil {
            addSublayer(leftTextLayer!)
        }
        if rightTextLayer != nil {
            addSublayer(rightTextLayer!)
        }
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    func redraw() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        lineLayer.path = path.cgPath
        
        leftTextLayer?.frame = bounds
        rightTextLayer?.frame = bounds
    }
}

extension YValueLayer: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        guard let source = source else { return }
        lineLayer.strokeColor = theme.gridLineColor.cgColor
        
        if let leftColor = source.leftColor {
            leftTextLayer?.foregroundColor = leftColor.cgColor
        } else {
            leftTextLayer?.foregroundColor = theme.axisTextColor.cgColor
        }
        if let rightColor = source.rightColor {
            rightTextLayer?.foregroundColor = rightColor.cgColor
        } else {
            rightTextLayer?.foregroundColor = theme.axisTextColor.cgColor
        }
    }
}
