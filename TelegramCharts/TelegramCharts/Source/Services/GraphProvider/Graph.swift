//
//  Graph.swift
//  TelegramCharts
//
//  Created by Rost on 09/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class Graph {
    var name: String
    var charts: [Chart]
    var dates: [Date]
    
    init(name: String, charts: [Chart], dates: [Date]) {
        self.name = name
        self.dates = dates
        self.charts = charts
    }
}

enum ChartType {
    case line
    case bar
    case area
}

class Chart {
    var type: ChartType
    var name: String
    var color: UIColor
    var values: [Int]
    var showPercent: Bool
    var stacked: Bool
    var yScaled: Bool
    
    init(type: ChartType,
         name: String,
         color: UIColor,
         values: [Int],
         showPercent: Bool = false,
         stacked: Bool = false,
         yScaled: Bool = false) {
        
        self.type = type
        self.yScaled = yScaled
        self.showPercent = showPercent
        self.stacked = stacked
        self.name = name
        self.color = color
        self.values = values
    }
}
