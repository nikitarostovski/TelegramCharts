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

    var xVisibleIndices: ClosedRange<Int>
    var yMaxVisible: CGFloat?

    init(y: [CGFloat], color: UIColor) {
        self.x = [CGFloat]()
        for i in y.indices {
            self.x.append(CGFloat(i) / CGFloat(y.count))
        }
        self.newNormX = x
        self.normX = x
        self.xVisibleIndices = 0 ... (x.count - 1)

        self.y = y
        self.newNormY = y
        self.normY = y

        self.color = color
    }

    func normalizeX(range: ClosedRange<CGFloat>) {
        var xNewLow = 0
        var xNewUp = x.count - 1
        for i in xVisibleIndices.lowerBound ..< x.count {
            self.newNormX[i] = (x[i] - range.lowerBound) / (range.upperBound - range.lowerBound)
            if self.newNormX[i] > 1 {
                xNewUp = i
                break
            }
        }
        for i in (0 ... xVisibleIndices.upperBound).reversed() {
            self.newNormX[i] = (x[i] - range.lowerBound) / (range.upperBound - range.lowerBound)
            if self.newNormX[i] < 0 {
                xNewLow = i
                break
            }
        }
        xVisibleIndices = xNewLow ... xNewUp

        var maxVisible: CGFloat = 0
        for i in xVisibleIndices {
            maxVisible = max(maxVisible, y[i])
        }
        yMaxVisible = maxVisible
    }

    func normalizeY(range: ClosedRange<CGFloat>) {
        for i in xVisibleIndices {
            newNormY[i] = (y[i] - range.lowerBound) / (range.upperBound - range.lowerBound)
        }
    }

    func updateX(phase: CGFloat) {
        for i in xVisibleIndices {
            let oldX = normX[i]
            let newX = newNormX[i]
            let x = oldX + (newX - oldX) * phase
            normX[i] = x
        }
    }

    func updateY(phase: CGFloat) {
        for i in xVisibleIndices {
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
