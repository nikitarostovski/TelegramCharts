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
    
    var maxVisibleY: CGFloat = 0
    
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
    
    func updateScaleY(phase: CGFloat) {
        print(maxVisibleY)
        lines.forEach { $0.updateScaleY(max: maxVisibleY, phase: phase) }
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
        maxVisibleY = 0
        lines.forEach { line in
            line.normalize(range: xVisibleRange)
            guard let normX = line.normX else { return }
            guard let normY = line.normY else { return }
            var lineMaxVisibleY: CGFloat = 0
            for i in 0 ..< normX.count {
                guard normX[i] >= 0 && normX[i] <= 1 else { continue }
                lineMaxVisibleY = max(lineMaxVisibleY, normY[i])
            }
            maxVisibleY = max(maxVisibleY, lineMaxVisibleY)
        }
    }
}

class ChartLine {
    
    var color: UIColor
    var x: [CGFloat]
    var y: [CGFloat]
    
    var normX: [CGFloat]?
    var normY: [CGFloat]?
    var lastNormY: [CGFloat]?
    var dispY: [CGFloat]?
    var dispPoints: [CGPoint] {
        var result = [CGPoint]()
        guard let normX = normX, let dispY = dispY else { return result }
        for i in 0 ..< normX.count {
            guard i < normX.count && i < dispY.count else { continue }
            result.append(CGPoint(x: normX[i], y: dispY[i]))
        }
        return result
    }
    
    init(x: [CGFloat], y: [CGFloat], color: UIColor) {
        self.x = x
        self.y = y
        self.color = color
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        lastNormY = normY
        normX = [CGFloat]()
        normY = [CGFloat]()
        for i in 0 ..< x.count {
            let xPos = x[i]
            let dX: CGFloat = (xPos - range.lowerBound) / (range.upperBound - range.lowerBound)
            normX!.append(dX)
            normY!.append(y[i])
        }
    }
    
    func updateScaleY(max: CGFloat, phase: CGFloat) {
        dispY = [CGFloat]()
        for i in 0 ..< (normY?.count ?? 0) {
            dispY?.append(lastNormY![i] + (normY![i] - lastNormY![i]) * max * phase)
        }
    }
}
