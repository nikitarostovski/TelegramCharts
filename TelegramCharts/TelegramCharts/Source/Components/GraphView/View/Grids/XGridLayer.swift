//
//  XGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class XGridLayer: CALayer {
    
    private var lineLayer: CAShapeLayer
    private var lineColor: UIColor?
    
    // MARK: - Lifecycle
    
    override init() {
        lineLayer = CAShapeLayer()
        super.init()
        addSublayer(lineLayer)
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Public
    
    func redraw() {
        let lineFrame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        lineLayer.frame = lineFrame
        lineLayer.lineWidth = 1
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        lineLayer.path = path
    }
}

extension XGridLayer: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        lineColor = theme.gridLineColor
        lineLayer.strokeColor = lineColor!.cgColor
    }
}
