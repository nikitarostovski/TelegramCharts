//
//  ChartViewProtocol.swift
//  TelegramCharts
//
//  Created by Rost on 10/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol ChartViewProtocol {
    var barWidth: CGFloat { get }
    func update()
}
