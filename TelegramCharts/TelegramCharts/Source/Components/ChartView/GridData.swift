//
//  GridData.swift
//  TelegramCharts
//
//  Created by Rost on 17/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GridData {
    var maxVisibleValue: Int64 = 0 {
        didSet {
            normalize()
        }
    }
    private var maxValue: Int64 = 0
    var sectionHeight: CGFloat = 100
    var maxVisibleSections = 5
    
    private var yLines = [GridLineData]()
    
    init(maxY: Int64) {
        self.maxValue = maxY
        for i in 0 ..< maxValue {
            let line = GridLineData(y: CGFloat(i) / CGFloat(maxValue), value: i)
            yLines.append(line)
        }
        print(yLines.count)
    }
    
    func updateAlpha(phase: CGFloat) {
        yLines.forEach { $0.updateAlpha(phase: phase) }
    }
    
    private func normalize() {
        yLines.forEach {
            let range = CGFloat(0) ... CGFloat(maxVisibleValue) / CGFloat(maxValue)
            $0.normalize(range: range)
            if $0.normY < 0 || $0.normY > 1 {
                $0.targetAlpha = 0
                $0.currentAlpha = 0
                $0.isHidden = true
            } else {
                $0.isHidden = false
                $0.targetAlpha = 1
                $0.currentAlpha = 1
            }
        }
    }
//
//    private func normalize() {
//        xPoints.forEach { $0.normalize(range: visibleRange) }
//        var leftIndex = 0
//        for i in xPoints.indices {
//            if xPoints[i].normX > 0 {
//                leftIndex = i
//                break
//            }
//        }
//        var rightIndex = 0
//        for i in xPoints.indices.reversed() {
//            if xPoints[i].normX < 1 {
//                rightIndex = i
//                break
//            }
//        }
//        var step = 1
//        var visibleCount = rightIndex - leftIndex + 1
//        while visibleCount > maxVisiblePositions {
//            step += 1
//            visibleCount = (rightIndex - leftIndex + 1) / step
//        }
//        var visibilityIterator = 0
//        for i in xPoints.indices {
//            if i == leftIndex || i == rightIndex {
//                xPoints[i].isHidden = false
//                xPoints[i].targetAlpha = 1
//                //                xPoints[i].currentAlpha = 1
//            } else if i < leftIndex || i > rightIndex {
//                xPoints[i].isHidden = true
//                xPoints[i].targetAlpha = 0
//                xPoints[i].currentAlpha = 0
//            } else {
//                xPoints[i].isHidden = false
//                if visibilityIterator == step {
//                    xPoints[i].targetAlpha = 1
//                } else {
//                    xPoints[i].targetAlpha = 0
//                }
//                visibilityIterator += 1
//                if visibilityIterator > step {
//                    visibilityIterator = 0
//                }
//            }
//        }
//    }
//
    
    func getLinesToDraw(viewport: CGRect) -> [GridLineData] {
        for line in yLines {
            guard !line.isHidden else { continue }
            let y = viewport.origin.y + viewport.height - (line.normY * viewport.height)
            line.dispY = y
        }
        return yLines
    }
}

class GridLineData {
    var y: CGFloat
    var value: Int64
    
    var isHidden = true
    var targetAlpha: CGFloat = 1
    var currentAlpha: CGFloat = 1
    
    var normY: CGFloat = 0
    var dispY: CGFloat = 0
    
    init(y: CGFloat, value: Int64) {
        self.y = y
        self.value = value
    }
    
    func updateAlpha(phase: CGFloat) {
        currentAlpha = currentAlpha + (targetAlpha - currentAlpha) * phase
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        normY = (y - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

