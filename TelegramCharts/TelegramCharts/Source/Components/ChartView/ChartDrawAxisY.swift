//
//  ChartDrawAxisY.swift
//  TelegramCharts
//
//  Created by Rost on 22/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawAxisY {
    /// Vertical positions of lines
    var linePositions: [CGFloat] = [0, 0.18, 0.36, 0.54, 0.72, 0.9]
    /// Defines how much must maxValue changed to reset points. 1.05 means 5 percent difference
    var updateThreshold: CGFloat = 1.05
    
    var points = [ChartDrawPointY]()
    var hidingPoints = [ChartDrawPointY]()
    var maxValue = 0 {
        didSet {
            let diff = CGFloat(max(maxValue, lastChangeValue)) / CGFloat(min(lastChangeValue, maxValue))
            if diff > updateThreshold {
                lastChangeValue = maxValue
                updatePoints()
            }
        }
    }
    
    private var lastChangeValue = 0
    
    init(maxValue: Int) {
        self.maxValue = maxValue
    }
    
    private func updatePoints() {
        hidingPoints = points.map { $0 }
        points.removeAll()
        for pos in linePositions {
            let point = ChartDrawPointY(value: Int(pos * CGFloat(maxValue)))
            points.append(point)
            if hidingPoints.contains(where: { $0.value == point.value }) {
                hidingPoints = hidingPoints.filter { $0.value != point.value }
                point.alpha = 1.0
            }
        }
    }
}

class ChartDrawPointY {
    var value: Int
    var title: String
    var alpha: CGFloat
    
    init(value: Int, initialAlpha: CGFloat = 0.5) {
        self.value = value
        self.title = String(number: value)
        self.alpha = initialAlpha
    }
}
