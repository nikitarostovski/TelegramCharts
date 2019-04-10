//
//  ChartLayerProtocol.swift
//  TelegramCharts
//
//  Created by Rost on 10/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol ChartLayerProtocol where Self: CALayer {
    
    init(color: UIColor, lineWidth: CGFloat)
    func updatePoints(points: [LineChartPoint])
    func updateScale(newScale: CGFloat)
    func updateAlpha(alpha: CGFloat)
    
    func resize()
    
    func select(index: Int)
    func moveSelection(index: Int)
    func hideSelection()
}
