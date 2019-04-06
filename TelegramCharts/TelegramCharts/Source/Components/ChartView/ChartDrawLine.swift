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
    var points: [ChartDrawPoint]
    
    var firstIndex = 0
    var lastIndex = 0
    
    var targetAlpha: CGFloat = 1
    
    var maxValue: Int
    
    init(color: UIColor, points: [Int]) {
        self.color = color
        self.points = [ChartDrawPoint]()
        self.maxValue = 0
        for i in points.indices {
            self.points.append(ChartDrawPoint(x: CGFloat(i) / CGFloat(points.count - 1), value: points[i]))
            self.maxValue = max(self.maxValue, points[i])
        }
    }
}

class ChartDrawPoint {
    var value: Int
    var originalX: CGFloat = 0
    var x: CGFloat = 0
    var isVisible: Bool = false
    
    init(x: CGFloat, value: Int) {
        self.originalX = x
        self.value = value
    }
}
