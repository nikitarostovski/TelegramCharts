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
    private weak var dataSource: YAxisDataSource?
    
    private var lineColor: UIColor?
    
    // MARK: - Lifecycle
    
    required init(source: YAxisDataSource) {
        self.dataSource = source
        self.lines = []
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
    
    func update() {
        guard let dataSource = dataSource,
            bounds != .zero
            else {
                return
        }
        sublayers?.forEach { $0.removeFromSuperlayer() }
        for source in dataSource.lines {
            let lineLayer = CAShapeLayer()
            lineLayer.strokeColor = lineColor?.cgColor
            lineLayer.lineWidth = 1
            lineLayer.lineCap = .round
            lineLayer.lineJoin = .round

            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
            lineLayer.path = path.cgPath
            
            lineLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
            lineLayer.position.y = (1 - source.pos) * bounds.height
            addSublayer(lineLayer)
        }
    }
}

extension YGridLayer: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        lineColor = theme.gridLineColor
        lines.forEach {
            $0.strokeColor = lineColor!.cgColor
        }
    }
}
