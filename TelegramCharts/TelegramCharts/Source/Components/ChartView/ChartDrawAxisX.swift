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
        }
    }
    
    private func recalcPoints(fromIndex: Int) {
        for i in firstTitleIndex ... lastTitleIndex {
            points[i].isHidden = true
        }
        guard firstTitleIndex > 0, lastTitleIndex < points.count, firstTitleIndex < lastTitleIndex else {
            return
        }
        let width: CGFloat = self.textWidth
        points[fromIndex].isHidden = false
        
        let getPointLeft: (ChartDrawPointX) -> CGFloat = { pt in
            return pt.x - width / 2
        }
        let getPointRight: (ChartDrawPointX) -> CGFloat = { pt in
            return pt.x + width / 2
        }
        
        var lastVisibleRight = getPointRight(points[fromIndex])
        var i = fromIndex + 1
        while i < points.count {
            let pt = points[i]
            let left = getPointLeft(pt)
            if left > lastVisibleRight {
                pt.isHidden = false
                lastVisibleRight = getPointRight(pt)
            } else {
                pt.isHidden = true
            }
            i += 1
        }
        
        var lastVisibleLeft = getPointLeft(points[fromIndex])
        i = fromIndex - 1
        while i > 0 {
            let pt = points[i]
            let right = getPointRight(pt)
            if right < lastVisibleLeft {
                pt.isHidden = false
                lastVisibleLeft = getPointLeft(pt)
            } else {
                pt.isHidden = true
            }
            i -= 1
        }
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
