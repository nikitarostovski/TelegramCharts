//
//  ChartDataModels.swift
//  TelegramCharts
//
//  Created by Rost on 21/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartXDrawAxis {
    
    var visibleDatesCount = 5
    var points: [ChartXDrawPoint]
    var selectionIndex: Int? {
        didSet {
            if let oldValue = oldValue {
                points[oldValue].isSelected = false
            }
            if let selectionIndex = selectionIndex {
                points[selectionIndex].isSelected = true
            }
        }
    }

    var firstIndex = 0 {
        didSet {
            updatePoints()
        }
    }
    var lastIndex = 0 {
        didSet {
            updatePoints()
        }
    }
    
    private var lastChangeValue = 0
    
    init(dates: [Date]) {
        self.points = [ChartXDrawPoint]()
        for i in dates.indices {
            let x = CGFloat(i) / CGFloat(dates.count - 1)
            let point = ChartXDrawPoint(value: dates[i], x: x)
            points.append(point)
        }
    }

    func getClosestIndex(position: CGFloat) -> Int {
        return Int(CGFloat(points.count) * position)
    }
    
    private func updatePoints() {

//        let step = (finishIndex - startIndex)

        for i in points.indices {
            let pt = points[i]
            /*if i < startIndex || i > finishIndex {
                pt.isHidden = true
                continue
            }
            if i % step == 0 {
                pt.isHidden = false
            } else {
                pt.isHidden = true
            }*/
            pt.isHidden = false
        }
    }
}

class ChartXDrawPoint {
    var originalX: CGFloat
    var x: CGFloat = 0
    var value: Date
    var title: String
    var alpha: CGFloat
    var isHidden = false
    var isSelected: Bool = false
    
    init(value: Date, x: CGFloat, initialAlpha: CGFloat = 1) {
        self.originalX = x
        self.value = value
        self.title = value.monthDayShortString()
        self.alpha = initialAlpha
    }
}

class ChartYDrawAxis {
    /// Vertical positions of lines
    var linePositions: [CGFloat] = [0, 0.18, 0.36, 0.54, 0.72, 0.9]
    /// Defines how much must maxValue changed to reset points. 1.05 means 5 percent difference
    var updateThreshold: CGFloat = 1.05
    
    var points = [ChartYDrawPoint]()
    var hidingPoints = [ChartYDrawPoint]()
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
            let point = ChartYDrawPoint(value: Int(pos * CGFloat(maxValue)))
            points.append(point)
            if hidingPoints.contains(where: { $0.value == point.value }) {
                hidingPoints = hidingPoints.filter { $0.value != point.value }
                point.alpha = 1.0
            }
        }
    }
}

class ChartYDrawPoint {
    var value: Int
    var title: String
    var alpha: CGFloat
    
    init(value: Int, initialAlpha: CGFloat = 0.5) {
        self.value = value
        self.title = String(number: value)
        self.alpha = initialAlpha
    }
}

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
    
    init(color: UIColor, points: [Int]) {
        self.color = color
        self.points = [ChartDrawPoint]()
        for i in points.indices {
            self.points.append(ChartDrawPoint(x: CGFloat(i) / CGFloat(points.count - 1), value: points[i]))
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
