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
    
    var attributes: [NSAttributedString.Key: Any]? {
        didSet {
            points.forEach { $0.attributes = attributes }
        }
    }
    private var lastChangeValue = 0
    
    init(maxValue: Int, attributes: [NSAttributedString.Key: Any]?) {
        self.attributes = attributes
        self.maxValue = maxValue
    }
    
    private func updatePoints() {
        hidingPoints = points.map { $0 }
        points.removeAll()
        for pos in linePositions {
            let point = ChartDrawPointY(value: Int(pos * CGFloat(maxValue)), attributes: attributes)
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
    var title: NSAttributedString
    var alpha: CGFloat
    
    var attributes: [NSAttributedString.Key: Any]? {
        didSet {
            title = NSAttributedString(string: String(number: value), attributes: attributes)
        }
    }
    
    init(value: Int, attributes: [NSAttributedString.Key: Any]?, initialAlpha: CGFloat = 0.2) {
        self.value = value
        self.title = NSAttributedString(string: String(number: value), attributes: attributes)
        self.alpha = initialAlpha
    }
}
