//
//  ChartAxis.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 18/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartGrid {

    var xPoints: [ChartAxisPoint]
    var yPoints: [ChartAxisPoint]

    var xAxisData: [Any]
    var yAxisMaxNumber: Int64
    var yLinesCount = 5

    var xVisibleIndices: ClosedRange<Int> = 0 ... 1

    init(xAxisData: [Any], yAxisMaxNumber: Int64) {
        self.xAxisData = xAxisData
        self.yAxisMaxNumber = yAxisMaxNumber
        xPoints = [ChartAxisPoint]()
        yPoints = [ChartAxisPoint]()
        for i in xAxisData.indices {
            let normalizedPosition = CGFloat(i) / CGFloat(xAxisData.count)
            let xPoint = ChartAxisPoint(position: normalizedPosition, title: String(i))
            xPoints.append(xPoint)
        }
    }

    func updateX(phase: CGFloat) {
        for i in xVisibleIndices.lowerBound ..< xVisibleIndices.upperBound {
            xPoints[i].update(phase: phase)
        }
    }

    func updateY(phase: CGFloat) {
        yPoints.forEach { $0.update(phase: phase) }
    }

    func normalizeX(range: ClosedRange<CGFloat>) {
        for p in xPoints {
            p.normalize(range: range)
        }
        var xNewLow = 0
        var xNewUp = xPoints.count - 1
        for i in xVisibleIndices.lowerBound ..< xPoints.count {
            if xPoints[i].normPos > 1 {
                xNewUp = i
                break
            }
        }
        for i in (0 ... xVisibleIndices.upperBound).reversed() {
            if xPoints[i].normPos < 0 {
                xNewLow = i
                break
            }
        }
        xVisibleIndices = xNewLow ... xNewUp
    }

    func normalizeY(range: ClosedRange<CGFloat>) {
        yPoints = yPoints.filter { !$0.isHidden }
        yPoints.forEach { $0.targetAlpha = 0 }
        let maxVisibleY = Int64(CGFloat(yAxisMaxNumber) * range.upperBound)
        let step = CGFloat(maxVisibleY) / CGFloat(yLinesCount)
        let numberStep = Int64(step + 0.5)
        for i in 0 ..< yLinesCount + 1 {
            let yValue = Int64(i) * numberStep
            let point = ChartAxisPoint(position: CGFloat(yValue) / CGFloat(yAxisMaxNumber), title: String(yValue))
            point.targetAlpha = 1
            point.currentAlpha = 0
            point.isHidden = false
            point.normalize(range: range)
            yPoints.append(point)
        }
    }
    
    func getClosedXAxisIndex(position: CGFloat) -> Int? {
        return Int(CGFloat(xAxisData.count) * position)
    }
}

class ChartAxisPoint {
    var position: CGFloat
    var title: String

    var isHidden = true
    var targetAlpha: CGFloat = 1
    var currentAlpha: CGFloat = 0

    var normPos: CGFloat = 0
    var newNormPos: CGFloat = 0

    init(position: CGFloat, title: String) {
        self.position = position
        self.title = title
    }

    func update(phase: CGFloat) {
        currentAlpha = currentAlpha + (targetAlpha - currentAlpha) * phase
        normPos = normPos + (newNormPos - normPos) * phase
        if currentAlpha < 0.01 {
            isHidden = true
            currentAlpha = 0
        }
    }

    func normalize(range: ClosedRange<CGFloat>) {
        newNormPos = (position - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

extension ChartGrid: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ChartGrid(xAxisData: self.xAxisData, yAxisMaxNumber: self.yAxisMaxNumber)
        copy.xPoints = self.xPoints
        copy.yPoints = self.yPoints
        return copy
    }
}

extension ChartAxisPoint: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ChartAxisPoint(position: self.position, title: self.title)
        copy.isHidden = self.isHidden
        copy.targetAlpha = self.targetAlpha
        copy.currentAlpha = self.currentAlpha
        copy.normPos = self.normPos
        return copy
    }
}
