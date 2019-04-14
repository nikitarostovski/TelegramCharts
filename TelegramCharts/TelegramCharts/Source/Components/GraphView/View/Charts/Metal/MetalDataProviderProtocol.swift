//
//  MetalChartDataProvider.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol MetalDataProvider: class {
    
    var lineWidth: CGFloat { get set }
    var renderData: [RenderVertex] { get }
    func update()
}
