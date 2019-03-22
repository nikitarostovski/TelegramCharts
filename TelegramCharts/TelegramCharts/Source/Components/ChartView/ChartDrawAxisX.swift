//
//  ChartDrawAxisX.swift
//  TelegramCharts
//
//  Created by Rost on 22/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawAxisX {

    private (set) var points: [ChartDrawPointX]
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
    
    private (set) var firstIndex = 0
    private (set) var lastIndex = 0
    private (set) var range: ClosedRange<CGFloat> = 0 ... 1
    
    private (set) var firstTitleIndex = 0
    private (set) var lastTitleIndex = 0
    
    private var textWidth: CGFloat = 0
    
    private var visibilityStep = 1
    private var visibilityAnchorIndex = 0
    
    func changeTextWidth(newWidth: CGFloat) {
        textWidth = newWidth
        recalcPoints(fromIndex: firstTitleIndex)
        updatePoints()
    }
    
    func changeLowerBound(newLow: CGFloat) {
        range = newLow ... range.upperBound
        recalcIndices()
        recalcPoints(fromIndex: lastTitleIndex)
        updatePoints()
    }
    
    func changeUpperBound(newUp: CGFloat) {
        range = range.lowerBound ... newUp
        recalcIndices()
        recalcPoints(fromIndex: firstTitleIndex)
        updatePoints()
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        recalcIndices()
        updatePoints()
    }
    
    init(dates: [Date]) {
        self.points = [ChartDrawPointX]()
        for i in dates.indices {
            let x = CGFloat(i) / CGFloat(dates.count - 1)
            let point = ChartDrawPointX(value: dates[i], x: x)
            points.append(point)
        }
    }
    
    func getClosestIndex(position: CGFloat) -> Int {
        return Int(CGFloat(points.count) * position)
    }
    
    private func recalcIndices() {
        firstIndex = max(Int(range.lowerBound * CGFloat(points.count - 1) - 0.5), 0)
        lastIndex = min(Int(range.upperBound * CGFloat(points.count - 1) + 0.5), points.count - 1)
        firstTitleIndex = max(Int(range.lowerBound * CGFloat(points.count - 1) - 0.5), 0)
        lastTitleIndex = min(Int(range.upperBound * CGFloat(points.count - 1) + 0.5), points.count - 1)
    }
    
    private func updatePoints() {
        for i in points.indices {
            let pt = points[i]
            pt.x = (pt.originalX - range.lowerBound) / (range.upperBound - range.lowerBound)
            if abs(i - visibilityAnchorIndex) % visibilityStep == 0 {
                pt.isHidden = false
            } else {
                pt.isHidden = true
            }
        }
    }
    
    private func recalcPoints(fromIndex: Int) {
        guard firstTitleIndex > 0, lastTitleIndex < points.count, firstTitleIndex < lastTitleIndex else {
            return
        }
        let getPointLeft: (ChartDrawPointX) -> CGFloat = { pt in
            return pt.x - self.textWidth / 2
        }
        let getPointRight: (ChartDrawPointX) -> CGFloat = { pt in
            return pt.x + self.textWidth / 2
        }
        points[fromIndex].isHidden = false
        let lastVisibleRight = getPointRight(points[fromIndex])
        let lastVisibleLeft = getPointLeft(points[fromIndex])
        
        var step: Int?
        var i = fromIndex + 1
        while i < points.count {
            let pt = points[i]
            let left = getPointLeft(pt)
            if left > lastVisibleRight {
                step = i - fromIndex
                break
            }
            i += 1
        }
        if step == nil {
            i = fromIndex - 1
            while i > 0 {
                let pt = points[i]
                let right = getPointRight(pt)
                if right < lastVisibleLeft {
                    step = fromIndex - i
                    break
                }
                i -= 1
            }
        }
        if step == nil {
            step = 1
        }
        visibilityAnchorIndex = fromIndex
        visibilityStep = step!
    }
}

class ChartDrawPointX {
    var originalX: CGFloat
    var x: CGFloat = 0
    var value: Date
    var title: String
    var alpha: CGFloat
    var isSelected: Bool = false
    var isHidden = false {
        didSet {
            targetAlpha = isHidden ? 0 : 1
        }
    }
    
    private (set) var targetAlpha: CGFloat
    
    init(value: Date, x: CGFloat, initialAlpha: CGFloat = 1) {
        self.originalX = x
        self.value = value
        self.alpha = initialAlpha
        self.targetAlpha = initialAlpha
        self.title = value.monthDayShortString()
    }
}
