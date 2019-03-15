//
//  ChartsData.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartsData {
    var lines: [ChartLine]
    
    init(lines: [ChartLine]) {
        self.lines = lines
    }
    
    init() {
        self.lines = [ChartLine]()
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        lines.forEach { $0.normalize(range: range) }
        guard let maxVisibleValue: Int64 = (lines.compactMap { $0.maxVisibleValue?.value ?? nil }).max() else { return }
        lines.forEach {
            $0.correctYPoints(maxVisibleValue: maxVisibleValue)
        }
    }
    
    func updateCurrentXPoints(phase: CGFloat) {
        lines.forEach {
            $0.updateCurrentXPoints(phase: phase)
        }
    }
    
    func updateCurrentYPoints(phase: CGFloat) {
        lines.forEach { $0.updateCurrentYPoints(phase: phase) }
    }
    
    func calculateDisplayValues(viewport: CGRect) {
        lines.forEach { $0.calculateDisplayPoints(viewport: viewport) }
    }
}

class ChartLine {
    var values = [ChartValue]()
    var color: UIColor = .clear
    
    var maxVisibleValue: ChartValue?
    
    init?(values: [Int64], xTitles: [String], color: UIColor) {
        guard values.count == xTitles.count else { return }
        self.values = [ChartValue]()
        self.color = color
        
        for i in 0 ..< values.count {
            let xTitle = xTitles[i]
            let value = values[i]
            let newValue = ChartValue(x: CGFloat(i) / CGFloat(values.count),
                                      value: value,
                                      xTitle: xTitle)
            self.values.append(newValue)
        }
        self.color = color
    }
    
    var displayPoints: [CGPoint] {
        return values.map { CGPoint(x: $0.displayX, y: $0.displayY) }
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        var maxVisible: Int64 = 0
        var maxVisibleIndex = 0
        for i in 0 ..< values.count {
            let value = values[i]
            let normX = CGFloat(i) / CGFloat(values.count)
            let xPos: CGFloat = (normX - range.lowerBound) / (range.upperBound - range.lowerBound)
            value.oldNormalizedX = value.currentNormalizedX
            value.newNormalizedX = xPos
            
            if value.newNormalizedX >= 0 && value.newNormalizedX <= 1 {
                if value.value > maxVisible {
                    maxVisible = value.value
                    maxVisibleIndex = i
                }
            }
        }
        maxVisibleValue = values[maxVisibleIndex]
    }
    
    func updateCurrentXPoints(phase: CGFloat) {
        values.indices.forEach { i in
            let value = values[i]
            let oldX = value.oldNormalizedX
            let newX = value.newNormalizedX
            value.currentNormalizedX = oldX + (newX - oldX) * phase
        }
    }
    
    func updateCurrentYPoints(phase: CGFloat) {
        values.forEach { value in
            let oldY = value.oldNormalizedY
            let newY = value.newNormalizedY
            value.currentNormalizedY = oldY + (newY - oldY) * phase
        }
    }
    
    func correctYPoints(maxVisibleValue: Int64) {
        values.forEach { value in
            value.oldNormalizedY = value.currentNormalizedY
            value.newNormalizedY = CGFloat(value.value) / CGFloat(maxVisibleValue)
        }
    }
    
    func calculateDisplayPoints(viewport: CGRect) {
        values.forEach { value in
            value.displayX = viewport.origin.x + value.currentNormalizedX * viewport.width
            value.displayY = viewport.origin.y + viewport.height * (1.0 - value.currentNormalizedY)
        }
    }
}

class ChartValue {
    var newNormalizedX: CGFloat = 0
    var newNormalizedY: CGFloat = 0
    var oldNormalizedX: CGFloat = 0
    var oldNormalizedY: CGFloat = 0
    var currentNormalizedX: CGFloat = 0
    var currentNormalizedY: CGFloat = 0
    var displayX: CGFloat = 0
    var displayY: CGFloat = 0
    
    var xTitle: String
    var value: Int64
    
    init(x: CGFloat, value: Int64, xTitle: String) {
        self.newNormalizedX = x
        self.oldNormalizedX = x
        self.currentNormalizedX = x
        self.newNormalizedY = CGFloat(value)
        self.oldNormalizedY = CGFloat(value)
        self.currentNormalizedY = CGFloat(value)
        self.xTitle = xTitle
        self.value = value
    }
}
