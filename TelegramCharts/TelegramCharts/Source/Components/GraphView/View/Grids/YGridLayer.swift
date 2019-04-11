//
//  YGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YGridLayer: CALayer {
    
    private var lines: [YValueLayer]
    private weak var dataSource: YAxisDataSource?
    
    // MARK: - Lifecycle
    
    required init(source: YAxisDataSource) {
        self.dataSource = source
        self.lines = []
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        guard let dataSource = dataSource,
            bounds != .zero
            else {
                return
        }
        sublayers?.forEach { $0.removeFromSuperlayer() }
        let textHeight: CGFloat = 14
        for lineSource in dataSource.lines {
            let lineLayer = YValueLayer(source: lineSource)
            lineLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: textHeight)
            lineLayer.position.y = (1 - lineSource.pos) * bounds.height - textHeight / 2
            lineLayer.redraw()
            addSublayer(lineLayer)
        }
    }
}
