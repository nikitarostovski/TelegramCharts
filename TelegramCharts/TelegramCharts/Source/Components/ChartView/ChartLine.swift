//
//  ChartLine.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 18/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartLine {

    var color: UIColor
    var x: [CGFloat]
    var y: [CGFloat]

    var normX: [CGFloat]
    var normY: [CGFloat]

    private var newNormX: [CGFloat]
    private var newNormY: [CGFloat]

    var yMaxVisible: CGFloat?

    init(y: [CGFloat], color: UIColor) {
        self.x = [CGFloat]()
        for i in y.indices {
            self.x.append(CGFloat(i) / CGFloat(y.count - 1))
        }
        self.newNormX = x
        self.normX = x

        self.y = y
        self.newNormY = y
        self.normY = y

        self.color = color
    }

    func normalizeX(range: ClosedRange<CGFloat>) {
        var left: Int?
        var right: Int?
        for i in x.indices {
            newNormX[i] = (x[i] - range.lowerBound) / (range.upperBound - range.lowerBound)
            if newNormX[i] >= 0 && left == nil && i > 0 {
                left = i - 1
            }
            if newNormX[i] > 1 && right == nil && i < (x.count - 1) {
                right = i + 1
            }
        }
        var maxVisible: CGFloat = 0
        left = left ?? 0
        right = right ?? x.count - 1
        for i in left! ... right! {
            maxVisible = max(maxVisible, y[i])
        }
        yMaxVisible = maxVisible
    }

    func normalizeY(range: ClosedRange<CGFloat>) {
        for i in y.indices {
            newNormY[i] = (y[i] - range.lowerBound) / (range.upperBound - range.lowerBound)
        }
    }

    func updateX(phase: CGFloat) {
        for i in x.indices {
            let oldX = normX[i]
            let newX = newNormX[i]
            let x = oldX + (newX - oldX) * phase
            normX[i] = x
        }
    }

    func updateY(phase: CGFloat) {
        for i in y.indices {
            let oldY = normY[i]
            let newY = newNormY[i]
            let y = oldY + (newY - oldY) * phase
            normY[i] = y
        }
    }
}

extension ChartLine: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ChartLine(y: self.y, color: self.color)
        copy.x = self.x
        copy.normX = self.normX
        copy.normY = self.normY
        return copy
    }
}
