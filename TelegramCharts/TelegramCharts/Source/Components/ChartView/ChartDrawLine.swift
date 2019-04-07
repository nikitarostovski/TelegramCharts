//
//  ChartDrawLine.swift
//  TelegramCharts
//
//  Created by Rost on 22/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawLine {
    var color: UIColor
    var alpha: CGFloat = 1
    var isHiding: Bool = false {
        didSet {
            targetAlpha = isHiding ? 0 : 1
        }
    }
    var name: String
    var points: [ChartDrawPoint]
    var maxValue: Int
    var targetAlpha: CGFloat = 1
    var tolerance: CGFloat = 0
    
    init(name: String, color: UIColor, points: [Int]) {
        self.name = name
        self.color = color
        self.points = [ChartDrawPoint]()
        self.maxValue = 0
        for i in points.indices {
            self.points.append(ChartDrawPoint(value: points[i]))
            self.maxValue = max(self.maxValue, points[i])
        }
    }
    
    func updateTolerance(visiblePoints: Int, visiblePixels: Int) {
        if visiblePoints < visiblePixels {
            tolerance = 0
            return
        }
        tolerance = CGFloat(visiblePoints) / CGFloat(visiblePixels)
    }
}

class ChartDrawPoint {
    var value: Int
    var isVisible: Bool = true
    
    init(value: Int) {
        self.value = value
    }
}
