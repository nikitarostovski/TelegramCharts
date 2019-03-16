//
//  ChartsData.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartsData {

    var xVisibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            normalize()
        }
    }
    
    private var lines: [ChartLine]
    
    init?(lines: [([Int64], UIColor)]) {
        self.lines = [ChartLine]()
        
        var maxValue: Int64 = 0
        for line in lines {
            guard let lineMaxValue = line.0.max() else { continue }
            maxValue = max(maxValue, lineMaxValue)
        }
        for lineIndex in lines.indices {
            let line = lines[lineIndex]
            
            var xPositions = [CGFloat]()
            var yPositions = [CGFloat]()
            
            for valueIndex in line.0.indices {
                let value = line.0[valueIndex]
                let normalizedX = CGFloat(valueIndex) / CGFloat(line.0.count)
                let normalizedY = CGFloat(value) / CGFloat(maxValue)
                xPositions.append(normalizedX)
                yPositions.append(normalizedY)
            }
            let chartLine = ChartLine(x: xPositions, y: yPositions, color: line.1)
            self.lines.append(chartLine)
        }
    }
    
    func getLinesToDraw(viewport: CGRect) -> [([CGPoint], UIColor)] {
        var result = [([CGPoint], UIColor)]()
        for line in lines {
            let convertedPoints: [CGPoint] = line.dispPoints.map {
                let x = viewport.origin.x + $0.x * viewport.width
                let y = viewport.origin.y + viewport.height * (1.0 - $0.y)
                return CGPoint(x: x, y: y)
            }
            result.append((convertedPoints, line.color))
        }
        return result
    }
    
    private func normalize() {
        lines.forEach {
            $0.normalize(range: xVisibleRange)
        }
    }
}

class ChartLine {
    
    var color: UIColor
    var x: [CGFloat]
    var y: [CGFloat]
    
    var dispX: [CGFloat]?
    var dispY: [CGFloat]?
    var dispPoints: [CGPoint] {
        var result = [CGPoint]()
        guard let dispX = dispX, let dispY = dispY else { return result }
        for i in 0 ..< dispX.count {
            guard i < dispX.count && i < dispY.count else { continue }
            result.append(CGPoint(x: dispX[i], y: dispY[i]))
        }
        return result
    }
    
    init(x: [CGFloat], y: [CGFloat], color: UIColor) {
        self.x = x
        self.y = y
        self.color = color
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        dispX = [CGFloat]()
        dispY = [CGFloat]()
        for i in 0 ..< x.count {
            let xPos = x[i]
            let dX: CGFloat = (xPos - range.lowerBound) / (range.upperBound - range.lowerBound)
            dispX!.append(dX)
            dispY!.append(y[i])
        }
    }
}
