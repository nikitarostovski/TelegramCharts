//
//  ChartsData.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartsData {
//    var dates = [Date]()
    var lines: [ChartLineData]

    init(lines: [ChartLineData]) {
        self.lines = lines
    }

    init() {
        self.lines = [ChartLineData]()
    }

    func normalize(range: ClosedRange<CGFloat>) {
        var maxVisibleValue: Int64 = 0
        lines.forEach { line in
            for i in 0 ..< line.values.count {
                let normX = CGFloat(i) / CGFloat(line.values.count)
                let xPos: CGFloat = (normX - range.lowerBound) / (range.upperBound - range.lowerBound)
                line.values[i].oldNormalizedX = line.values[i].currentNormalizedX
                line.values[i].newNormalizedX = xPos
            }
            line.values.forEach { value in
                guard value.newNormalizedX >= 0 && value.newNormalizedX <= 1 else { return }
                maxVisibleValue = max(maxVisibleValue, value.value)
            }
        }
        lines.forEach { line in
            line.values.forEach { value in
                let yPos = CGFloat(value.value) / CGFloat(maxVisibleValue)
                value.oldNormalizedY = value.currentNormalizedY
                value.newNormalizedY = yPos
            }
        }
    }

    func updateCurrentPoints(phase: CGFloat) {
        lines.forEach { line in
            line.values.forEach { value in
                let oldX = value.oldNormalizedX
                let newX = value.newNormalizedX
                let oldY = value.oldNormalizedY
                let newY = value.newNormalizedY
                value.currentNormalizedX = newX//oldX + (newX - oldX) * phase
                value.currentNormalizedY = newY//oldY + (newY - oldY) * phase
            }
        }
    }

    func calculateDisplayValues(viewport: CGRect) {
        for lineIndex in 0 ..< lines.count {
            let line = lines[lineIndex]
            for valueIndex in 0 ..< line.values.count {
                let value = line.values[valueIndex]
                value.displayX = viewport.origin.x + value.currentNormalizedX * viewport.width
                value.displayY = viewport.origin.y + viewport.height * (1.0 - value.currentNormalizedY)
            }
        }
    }
}

class ChartLineData {
    var values: [ChartValueData]
    var color: UIColor

    var displayPoints: [CGPoint] {
        return values.map { $0.displayPoint }
    }

    init(values: [Int64], color: UIColor) {
        self.values = values.map { ChartValueData(value: $0) }
        self.color = color
    }
}

class ChartValueData {
    var value: Int64
    var newNormalizedX: CGFloat = 0
    var newNormalizedY: CGFloat = 0
    var oldNormalizedX: CGFloat = 0
    var oldNormalizedY: CGFloat = 0
    var currentNormalizedX: CGFloat = 0
    var currentNormalizedY: CGFloat = 0
    var displayX: CGFloat = 0
    var displayY: CGFloat = 0

    var displayPoint: CGPoint {
        return CGPoint(x: displayX, y: displayY)
    }

    init(value: Int64) {
        self.value = value
    }
}
