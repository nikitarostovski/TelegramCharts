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
    var percentage: Bool
    var stacked: Bool
    var yScaled: Bool
    
    init(name: String, charts: [Chart], dates: [Date], percentage: Bool, stacked: Bool, yScaled: Bool) {
        self.name = name
        self.dates = dates
        self.charts = charts
        self.yScaled = yScaled
        self.percentage = percentage
        self.stacked = stacked
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
    
    init(type: ChartType,
         name: String,
         color: UIColor,
         values: [Int]) {
        
        self.type = type
        self.name = name
        self.color = color
        self.values = values
    }
}
