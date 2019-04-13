//
//  YGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YGridLayer: CALayer {
    
    private var lines: [CAShapeLayer]
    private var gradients: [CAGradientLayer]
    private var values: [YValueData]
    private weak var dataSource: YAxisDataSource?
    
    private var lineColor: UIColor?
    
    // MARK: - Lifecycle
    
    required init(source: YAxisDataSource) {
        self.dataSource = source
        self.lines = []
        self.gradients = []
        self.values = []
        super.init()
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Public
    
    func resetValues() {
        guard let dataSource = dataSource,
            let lineColor = lineColor,
            bounds != .zero
        else {
            return
        }
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        gradients = []
        values = dataSource.values + dataSource.lastValues
        for source in values {
            let lineFrame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
            let lineLayer = CAShapeLayer()
            lineLayer.frame = lineFrame
            lineLayer.opacity = Float(source.fadePhase)
            lineLayer.lineWidth = 1
            lineLayer.lineCap = .round
            lineLayer.lineJoin = .round
            lines.append(lineLayer)
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
            lineLayer.path = path
            
            if dataSource.alignment != .fill {
                var colors: [CGColor]!
                var locations: [NSNumber]!
                if dataSource.alignment == .left {
                    colors = [lineColor.cgColor, lineColor.cgColor, UIColor.clear.cgColor]
                    locations = [0.0, 0.33, 1.0]
                } else {
                    colors = [UIColor.clear.cgColor, lineColor.cgColor, lineColor.cgColor]
                    locations = [0.0, 0.67, 1.0]
                }
                let gradientLayer = CAGradientLayer()
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradientLayer.locations = locations
                gradientLayer.colors = colors
                gradientLayer.frame = lineFrame
                gradients.append(gradientLayer)
                
                lineLayer.addSublayer(gradientLayer)
            } else {
                lineLayer.strokeColor = lineColor.cgColor
            }
            addSublayer(lineLayer)
        }
//        updatePositions()
    }
    
    func updatePositions() {
        guard let dataSource = dataSource,
            bounds != .zero
        else {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lines.indices.forEach { i in
            let line = lines[i]
            line.opacity = Float(values[i].fadePhase)
            
            let normY = (values[i].value - dataSource.viewport.yLo) / dataSource.viewport.height
            line.position.y = (1 - normY) * bounds.height
        }
        CATransaction.commit()
    }
}

extension YGridLayer: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        lineColor = theme.gridLineColor
        guard let dataSource = dataSource else { return }
        if dataSource.alignment != .fill {
            var colors = [lineColor!.cgColor, lineColor!.cgColor, UIColor.clear.cgColor]
            if dataSource.alignment == .right {
                colors = colors.reversed()
            }
            gradients.forEach { $0.colors = colors }
        } else {
            lines.forEach { $0.strokeColor = lineColor!.cgColor }
        }
    }
}
