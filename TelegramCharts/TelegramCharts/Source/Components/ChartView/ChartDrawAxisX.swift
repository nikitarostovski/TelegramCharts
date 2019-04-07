//
//  ChartDrawAxisX.swift
//  TelegramCharts
//
//  Created by Rost on 22/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawAxisX {

    /// X axis points
    private (set) var points: [ChartDrawPointX]
    
    /// Index of selected point
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
    /// Title strings attributes
    var attributes: [NSAttributedString.Key: Any]? {
        didSet {
            points.forEach { $0.attributes = attributes }
        }
    }
    
    /// Visible area range
    private (set) var range: ClosedRange<CGFloat>
    
    /*private var textWidth: CGFloat = 1 {
        didSet {
            recalcTitleStep()
            if anchorTitleIndex == firstVisibleTitleIndex {
                calcLastVisibleTitleIndex()
            } else {
                calcFirstVisibleTitleIndex()
            }
            for i in points.indices {
                if (i - anchorTitleIndex) % titleStep == 0 {
                    points[i].isHidden = false
                    points[i].alpha = 1
                } else {
                    points[i].isHidden = true
                    points[i].alpha = 0
                }
            }
            updatePoints()
        }
    }*/
    
    // MARK: - Public methods
    
    /*func changeTextWidth(newWidth: CGFloat) {
        textWidth = newWidth
        updatePoints()
    }*/
    
    func changeLowerBound(newLow: CGFloat) {
        let step = range.lowerBound - newLow
        range = newLow ... range.upperBound
//        recalcTitleStep()
//        scaleTitlesFromRight()
        updatePoints(step: step)
    }
    
    func changeUpperBound(newUp: CGFloat) {
        let step = range.upperBound - newUp
        range = range.lowerBound ... newUp
//        recalcTitleStep()
//        scaleTitlesFormLeft()
        updatePoints(step: step)
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        /*if anchorTitleIndex == firstVisibleTitleIndex {
            calcLastVisibleTitleIndex()
        } else {
            calcFirstVisibleTitleIndex()
        }
        for i in points.indices {
            if (i - anchorTitleIndex) % titleStep == 0 {
                points[i].isHidden = false
                points[i].alpha = 1
            } else {
                points[i].isHidden = true
                points[i].alpha = 0
            }
        }*/
        updatePoints()
    }
    
    init(dates: [Date], attributes: [NSAttributedString.Key: Any]?, range: ClosedRange<CGFloat>) {
        self.points = [ChartDrawPointX]()
        for i in dates.indices {
            let x = CGFloat(i + 1) / CGFloat(dates.count + 1)
            let point = ChartDrawPointX(value: dates[i], x: x, attributes: attributes)
            points.append(point)
        }
        self.attributes = attributes
        /*self.firstVisibleTitleIndex = 0
        self.lastVisibleTitleIndex = points.count - 1
        self.anchorTitleIndex = self.lastVisibleTitleIndex*/
        self.range = range
//        recalcTitleStep()
    }
    
    func getClosestIndex(position: CGFloat) -> Int {
        return min(max(Int(CGFloat(points.count) * position), 0), points.count - 1)
    }
    
    // MARK: - Private methods
    
    private func updatePoints(step: CGFloat = 0) {
//        let step = abs(step) / textWidth
//        for i in firstIndex ... lastIndex {
            //points[i].alpha += step * (points[i].isHidden ? -1 : 1)
//        }
    }
    
    // MARK: - Titles calculations
    
    /*private var firstVisibleTitleIndex: Int
    private var lastVisibleTitleIndex: Int
    
    private var anchorTitleIndex: Int
    
    private var titleStep = 1
    
    private func scaleTitlesFormLeft() {
        calcFirstVisibleTitleIndex()
        for i in points.indices {
            if (i - anchorTitleIndex) % titleStep == 0 {
                points[i].isHidden = false
            } else {
                points[i].isHidden = true
            }
        }
    }
    
    private func scaleTitlesFromRight() {
        calcLastVisibleTitleIndex()
        for i in points.indices {
            if (i - anchorTitleIndex) % titleStep == 0 {
                points[i].isHidden = false
            } else {
                points[i].isHidden = true
            }
        }
    }
    
    private func recalcTitleStep() {
        let targetVisibleTitlesCount = max(1, Int(CGFloat(1) / textWidth))
        let scale = range.upperBound - range.lowerBound
        let newStep = max(1, Int(CGFloat(points.count) * scale / CGFloat(targetVisibleTitlesCount)))
        
        var i = 1
        var newStepClamped = 1
        while newStepClamped < newStep {
            newStepClamped = Int(pow(Float(2), Float(i)))
            i += 1
        }
        titleStep = newStepClamped
    }
    
    private func calcFirstVisibleTitleIndex() {
        var newFirstTitleIndex = lastVisibleTitleIndex
        for i in (0 ... lastIndex).reversed() {
            if points[i].x < 0 {
                break
            }
            if i % titleStep == 0 {
                newFirstTitleIndex = i
            }
        }
        firstVisibleTitleIndex = newFirstTitleIndex
    }
    
    func calcLastVisibleTitleIndex() {
        var newLastTitleIndex = firstVisibleTitleIndex
        for i in firstIndex ... points.count - 1 {
            if points[i].x > 1 {
                break
            }
            if i % titleStep == 0 {
                newLastTitleIndex = i
            }
        }
        lastVisibleTitleIndex = newLastTitleIndex
    }
    
    private func pointsPerTitle() -> CGFloat {
        return textWidth * ((range.upperBound - range.lowerBound) * CGFloat(points.count))
    }
    
    var titleStartIndex: Int {
        let offset = Int(pointsPerTitle() + 0.5)
        return max(firstIndex - offset, 0)
    }
    
    var titleEndIndex: Int {
        let offset = Int(pointsPerTitle() + 0.5)
        return min(lastIndex + offset, points.count - 1)
    }*/
}

class ChartDrawPointX {
    var originalX: CGFloat
    var x: CGFloat = 0
    var value: Date
    var title: NSAttributedString!
    var titleWidth: CGFloat!
    var alpha: CGFloat
    var isSelected: Bool = false
    var isHidden = false {
        didSet {
            targetAlpha = isHidden ? 0 : 1
            alpha = targetAlpha
        }
    }
    var attributes: [NSAttributedString.Key: Any]? {
        didSet {
            updateTitle()
        }
    }
    
    private (set) var targetAlpha: CGFloat
    
    init(value: Date, x: CGFloat, initialAlpha: CGFloat = 1, attributes: [NSAttributedString.Key: Any]?) {
        self.originalX = x
        self.value = value
        self.alpha = initialAlpha
        self.targetAlpha = initialAlpha
        self.attributes = attributes
        
        self.title = NSAttributedString()
        self.titleWidth = 0
        updateTitle()
    }
    
    private func updateTitle() {
        // TODO: bottleneck
//        title = NSAttributedString(string: value.monthDayShortString(), attributes: attributes)
//        titleWidth = title.width(withConstrainedHeight: .greatestFiniteMagnitude)
    }
}
