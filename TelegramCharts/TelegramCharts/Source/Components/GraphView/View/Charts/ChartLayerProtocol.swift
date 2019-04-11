//
//  ChartLayerProtocol.swift
//  TelegramCharts
//
//  Created by Rost on 10/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ChartLayerProtocolType = (ChartLayerProtocol & CALayer)

protocol ChartLayerProtocol where Self: CALayer {
    
    init(source: ChartDataSource, lineWidth: CGFloat)
    func update()
}
