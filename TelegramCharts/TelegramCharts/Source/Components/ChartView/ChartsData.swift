//
//  ChartsData.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol Printable {
    var title: NSAttributedString { get }
    var size: CGSize { get }
}

class PrintableDate: Printable {
    var title: NSAttributedString
    var size: CGSize
    
    private var date: Date
    
    init(date: Date) {
        self.date = date
        let string = date.stringValue()
        let attributes = [.font: UIFont.systemFont(ofSize: 12.0, weight: .regular)] as [NSAttributedString.Key : Any]
        title = NSAttributedString(string: string, attributes: attributes)
        
        let height: CGFloat = 21
        let width = title.width(withConstrainedHeight: height)
        size = CGSize(width: width, height: height)
    }
}

class PrintableNumber: Printable {
    var title: NSAttributedString
    var size: CGSize
    
    private var number: Int64
    
    init(number: Int64) {
        self.number = number
        let string = String(number)
        let attributes = [.font: UIFont.systemFont(ofSize: 12.0, weight: .regular)] as [NSAttributedString.Key : Any]
        title = NSAttributedString(string: string, attributes: attributes)
        
        let height: CGFloat = 21
        let width = title.width(withConstrainedHeight: height)
        size = CGSize(width: width, height: height)
    }
}

class ChartsData {

    var xVisibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            normalize()
        }
    }
    
    private var xTitles: [Printable]
    private var lines: [ChartLine]
    
    init?(xTitles: [Printable], lines: [([Int64], UIColor)]) {
        self.xTitles = xTitles
        self.lines = [ChartLine]()
        
        for line in lines {
            guard line.0.count == xTitles.count  else { return }
        }
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
                let normalizedX = CGFloat(valueIndex) / CGFloat(xTitles.count)
                let normalizedY = CGFloat(value) / CGFloat(maxValue)
                xPositions.append(normalizedX)
                yPositions.append(normalizedY)
            }
            let yTitles: [Printable] = line.0.map { PrintableNumber(number: $0) }
            let chartLine = ChartLine(yTitles: yTitles, x: xPositions, y: yPositions, color: line.1)
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
    
    func getTitlesToDraw(viewport: CGRect) -> [(NSAttributedString, CGRect)] {
        var result = [(NSAttributedString, CGRect)]()
        guard let line = lines.first,
            let dispX = line.dispX else {
            return result
        }
        var points = [CGPoint]()
        for i in xTitles.indices {
            let title = xTitles[i]
            let dX = dispX[i]
            let x = dX * viewport.width - title.size.width / 2
            let y = viewport.height - title.size.height
            
            result.append((title.title, CGRect(x: x, y: y, width: title.size.width, height: title.size.height)))
            points.append(CGPoint(x: x, y: y))
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
    
    var yTitles: [Printable]
    
    init(yTitles: [Printable], x: [CGFloat], y: [CGFloat], color: UIColor) {
        self.yTitles = yTitles
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
/*class ChartsData {
    var lines: [ChartLine]
    
    init(lines: [ChartLine]) {
        self.lines = lines
    }
    
    init() {
        self.lines = [ChartLine]()
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        lines.forEach { $0.normalize(range: range) }
    }
    
    func updateCurrentXPoints(phase: CGFloat) {
        var maxY: Int64 = 0
        lines.forEach {
            $0.updateCurrentXPoints(phase: phase)
            if $0.maxVisibleValue?.value ?? 0 > maxY {
                maxY = $0.maxVisibleValue?.value ?? maxY
            }
            $0.correctYPoints(maxVisibleValue: maxY)
        }
    }
    
    func updateCurrentYPoints(phase: CGFloat) {
        lines.forEach { $0.updateCurrentYPoints(phase: phase) }
    }
    
    func calculateDisplayValues(viewport: CGRect) {
        lines.forEach { $0.calculateDisplayPoints(viewport: viewport) }
    }
    
    func calculateDisplayTitles(viewport: CGRect) {
        let 
    }
}

class ChartLine {
    var values = [ChartValue]()
    var color: UIColor = .clear
    
    var maxVisibleValue: ChartValue?
    
    init?(values: [Int64], xTitles: [NSAttributedString], color: UIColor) {
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
    
    var displayValues: [ChartValue] {
        return values
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        for i in 0 ..< values.count {
            let value = values[i]
            let normX = CGFloat(i) / CGFloat(values.count)
            let xPos: CGFloat = (normX - range.lowerBound) / (range.upperBound - range.lowerBound)
            value.oldNormalizedX = value.currentNormalizedX
            value.newNormalizedX = xPos
        }
    }
    
    func updateCurrentXPoints(phase: CGFloat) {
        var maxVisible: Int64 = 0
        var maxVisibleIndex = 0
        values.indices.forEach { i in
            let value = values[i]
            let oldX = value.oldNormalizedX
            let newX = value.newNormalizedX
            value.currentNormalizedX = oldX + (newX - oldX) * phase
            
            if value.currentNormalizedX >= 0 && value.currentNormalizedX <= 1 {
                if value.value > maxVisible {
                    maxVisible = value.value
                    maxVisibleIndex = i
                }
            }
        }
        
        maxVisibleValue = values[maxVisibleIndex]
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
    
    var xTitleSize: CGSize = .zero
    
    var xTitle: NSAttributedString
    var value: Int64
    
    init(x: CGFloat, value: Int64, xTitle: NSAttributedString) {
        self.newNormalizedX = x
        self.oldNormalizedX = x
        self.currentNormalizedX = x
        self.newNormalizedY = CGFloat(value)
        self.oldNormalizedY = CGFloat(value)
        self.currentNormalizedY = CGFloat(value)
        self.xTitle = xTitle
        self.value = value
        
        calculateTitleSize()
    }
    
    private func calculateTitleSize() {
        let height: CGFloat = 21
        let width = xTitle.width(withConstrainedHeight: height)
        xTitleSize = CGSize(width: width, height: height)
    }
}
*/
