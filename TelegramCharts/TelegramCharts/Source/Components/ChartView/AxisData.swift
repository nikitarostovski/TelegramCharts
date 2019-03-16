//
//  AxisData.swift
//  TelegramCharts
//
//  Created by Rost on 16/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class AxisData {
    var visibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            normalize()
        }
    }
    var textWidth: CGFloat = 100
    var xPoints: [XAxisData]
    var maxVisiblePositions = 5
    
    init(xTitles: [String]) {
        self.xPoints = [XAxisData]()
        for i in 0 ..< xTitles.count {
            let x = CGFloat(i) / CGFloat(xTitles.count)
            xPoints.append(XAxisData(x: x, title: xTitles[i]))
        }
    }
    
    func updateAlpha(phase: CGFloat) {
        xPoints.forEach { $0.updateAlpha(phase: phase) }
    }
    
    private func normalize() {
        xPoints.forEach { $0.normalize(range: visibleRange) }
        var leftIndex = 0
        for i in xPoints.indices {
            if xPoints[i].normX > 0 {
                leftIndex = i
                break
            }
        }
        var rightIndex = 0
        for i in xPoints.indices.reversed() {
            if xPoints[i].normX < 1 {
                rightIndex = i
                break
            }
        }
        var step = 1
        var visibleCount = rightIndex - leftIndex + 1
        while visibleCount > maxVisiblePositions {
            step += 1
            visibleCount = (rightIndex - leftIndex + 1) / step
        }
        var visibilityIterator = 0
        for i in xPoints.indices {
            if i == leftIndex || i == rightIndex {
                xPoints[i].isHidden = false
                xPoints[i].targetAlpha = 1
//                xPoints[i].currentAlpha = 1
            } else if i < leftIndex || i > rightIndex {
                xPoints[i].isHidden = true
                xPoints[i].targetAlpha = 0
                xPoints[i].currentAlpha = 0
            } else {
                xPoints[i].isHidden = false
                if visibilityIterator == step {
                    xPoints[i].targetAlpha = 1
                } else {
                    xPoints[i].targetAlpha = 0
                }
                visibilityIterator += 1
                if visibilityIterator > step {
                    visibilityIterator = 0
                }
            }
        }
    }
    
    func getTextToDraw(viewport: CGRect) -> [XAxisData] {
        for point in xPoints {
            guard !point.isHidden else { continue }
            let x = viewport.origin.x + point.normX * viewport.width
            point.dispX = x
        }
        return xPoints
    }
}

class XAxisData {
    var x: CGFloat
    var title: String
    
    var isHidden = true
    var targetAlpha: CGFloat = 1
    var currentAlpha: CGFloat = 1
    
    var normX: CGFloat = 0
    var dispX: CGFloat = 0
    
    init(x: CGFloat, title: String) {
        self.x = x
        self.title = title
    }
    
    func updateAlpha(phase: CGFloat) {
        currentAlpha = currentAlpha + (targetAlpha - currentAlpha) * phase
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        normX = (x - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}
