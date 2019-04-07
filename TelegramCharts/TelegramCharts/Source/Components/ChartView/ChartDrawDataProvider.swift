//
//  ChartDrawDataProvider.swift
//  TelegramCharts
//
//  Created by Rost on 05/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawDataProvider: NSObject, ChartDataSource {
    
    var range: ClosedRange<CGFloat>
    
    var drawLines: [ChartDrawLine]
    var linesVisibility: [Bool]?
    
    var xDrawAxis: ChartDrawAxisX
    var dateTextWidth: CGFloat = 60
    var xAxisTextSpacing: CGFloat = 20
    
    var yDrawAxis: ChartDrawAxisY
    var yAxisGridStep: CGFloat = 0.18
    var maxValue: Int
    var maxVisibleValue: Int
    
    var maxVisibleY: CGFloat
    var targetMaxVisibleY: CGFloat
    
    var maxTotalVisibleY: CGFloat
    var targetMaxTotalVisibleY: CGFloat
    
    var gridMainColor: UIColor = .darkGray
    var gridAuxColor: UIColor = .lightGray
    var backColor: UIColor = .white
    
    var visibleIndices = [Int]()
    
    var redrawHandler: (() -> Void)?
    var mapRedrawHandler: (() -> Void)?
    var updateAlphaHandler: (() -> Void)?
    var updateMaxYHandler: (() -> Void)?
    
    var updateSelectionHandler: (() -> Void)?
    var hideSelectionHandler: (() -> Void)?
    
    private var maxVisiblePointsCount: Int = 2
//    private var fadeAnimator = Animator()
//    private var xAnimator = Animator()
//    private var yAnimator = Animator()
    
    init(lines: [ChartLine], dates: [Date], range: ClosedRange<CGFloat>) {
        self.maxValue = 0
        self.range = range
        self.drawLines = [ChartDrawLine]()
        self.linesVisibility = [Bool]()
        for line in lines {
            drawLines.append(ChartDrawLine(name: line.name, color: line.color, points: line.values))
            maxValue = max(maxValue, line.values.max() ?? 0)
            linesVisibility!.append(true)
        }
        maxVisibleValue = maxValue
        maxVisibleY = CGFloat(maxValue)
        maxTotalVisibleY = CGFloat(maxValue)
        targetMaxVisibleY = CGFloat(maxValue)
        targetMaxTotalVisibleY = CGFloat(maxValue)
        
        self.xDrawAxis = ChartDrawAxisX(dates: dates, attributes: [:], range: range)
        self.yDrawAxis = ChartDrawAxisY(maxValue: maxValue, attributes: [:])
        
        dateTextWidth = 0
//        for p in xDrawAxis.points {
//            let width = p.title.width(withConstrainedHeight: .greatestFiniteMagnitude)
//            dateTextWidth = max(dateTextWidth, width)
//        }
//        dateTextWidth += xAxisTextSpacing
        
        super.init()
        self.recalcVisibleIndices()
        self.updateYAxisDrawPositions()
        self.startReceivingThemeUpdates()
        
        recalc(animated: false)
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    func viewSizeChanged(newSize: CGSize) {
        let pixels = Int(newSize.width * UIScreen.main.scale)
        if pixels != maxVisiblePointsCount {
            maxVisiblePointsCount = pixels
        }
        updateTolerance()
//        xDrawAxis.changeTextWidth(newWidth: dateTextWidth / newSize.width)
    }
    
    func setLineVisibility(index: Int, visible: Bool, animated: Bool = true) {
        let line = drawLines[index]
        if line.isHiding == visible {
            line.isHiding = !visible
        }
        recalc()
        
        for drawLine in drawLines {
            drawLine.alpha = drawLine.targetAlpha
        }
        updateAlphaHandler?()
        redraw(main: true, map: true)
    }
    
    func changeLowerBound(newLow: CGFloat) {
        self.range = newLow ... range.upperBound
        xDrawAxis.changeLowerBound(newLow: newLow)
        recalcVisibleIndices()
        updateTolerance()
        recalc()
    }
    
    func changeUpperBound(newUp: CGFloat) {
        self.range = range.lowerBound ... newUp
        xDrawAxis.changeUpperBound(newUp: newUp)
        recalcVisibleIndices()
        recalc()
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        xDrawAxis.changePoisition(newLow: newLow)
        recalcVisibleIndices()
        hideSelection()
        recalc()
    }
    
    // MARK: - Private
    
    private func recalcVisibleIndices() {
        let lo = max(Int(range.lowerBound * CGFloat(xDrawAxis.points.count) - 0.5), 0)
        let hi = min(Int(range.upperBound * CGFloat(xDrawAxis.points.count) + 0.5), xDrawAxis.points.count - 1)
        var newIndices = [Int]()
        for i in lo ... hi {
            newIndices.append(i)
        }
        visibleIndices = newIndices
    }
    
    private func updateTolerance() {
        let points = visibleIndices.last! - visibleIndices.first! + 1
        drawLines.forEach {
            $0.updateTolerance(visiblePoints: points, visiblePixels: maxVisiblePointsCount)
        }
    }
    
    private func redraw(main: Bool = true, map: Bool = false) {
        DispatchQueue.main.async {
            if main {
                self.redrawHandler?()
            }
            if map {
                self.mapRedrawHandler?()
            }
        }
    }
    
    private func hideSelection() {
        DispatchQueue.main.async {
            self.hideSelectionHandler?()
        }
    }
    
    private func recalc(animated: Bool = true) {
        var newMaxVisibleValue = 0
        var newTotalMaxVisibleValue = 0
        
        let rangeSizeInv = CGFloat(1) / (range.upperBound - range.lowerBound)
        for j in visibleIndices {
            xDrawAxis.points[j].x = (xDrawAxis.points[j].originalX - range.lowerBound) * rangeSizeInv
            for i in drawLines.indices {
                let drawLine = drawLines[i]
                if !drawLine.isHiding {
                    newTotalMaxVisibleValue = max(newTotalMaxVisibleValue, drawLine.maxValue)
                    newMaxVisibleValue = max(newMaxVisibleValue, drawLine.points[j].value)
                }
            }
        }
        
        if maxVisibleValue != newMaxVisibleValue {
            targetMaxTotalVisibleY = CGFloat(newTotalMaxVisibleValue)
            updateMaxVisibleValue(value: newMaxVisibleValue, animated: animated)
        }
        redraw()
    }
    
    private func updateMaxVisibleValue(value: Int, animated: Bool = true) {
        maxVisibleValue = value
        yDrawAxis.maxValue = maxVisibleValue
        targetMaxVisibleY = CGFloat(maxVisibleValue)
        
        maxVisibleY = targetMaxVisibleY
        maxTotalVisibleY = targetMaxTotalVisibleY
        /*for pt in yDrawAxis.hidingPoints {
            pt.alpha = pt.alpha - pt.alpha * phase
        }
        for pt in yDrawAxis.points {
            pt.alpha = pt.alpha + (1 - pt.alpha) * phase
        }*/
        
        updateMaxYHandler?()
        redraw()
    }
    
    private func updateYAxisDrawPositions() {
        var yPositions = [CGFloat]()
        var pos: CGFloat = 0
        while pos < 1.0 {
            yPositions.append(pos)
            pos += yAxisGridStep
        }
        yDrawAxis.linePositions = yPositions
    }
    
    private func updateXTitles(animated: Bool = true) {
        /*let updateHandler: (CGFloat) -> Void = { [weak self] phase in
            guard let self = self else { return }
            for i in self.xDrawAxis.firstIndex ... self.xDrawAxis.lastIndex {
                let pt = self.xDrawAxis.points[i]
                pt.alpha = pt.alpha + (pt.targetAlpha - pt.alpha) * phase
            }
            self.redraw()
        }
        if animated {
            xAnimator.animate(duration: 2, update: updateHandler)
        } else {
            updateHandler(1)
        }*/
    }
    
    // MARK: - Plate data
    
    var plateData: SelectionData? {
        guard let selectionIndex = xDrawAxis.selectionIndex else { return nil }
        let date = xDrawAxis.points[selectionIndex].value
        var values = [Int]()
        var titles = [String]()
        var colors = [UIColor]()
        for drawLine in drawLines {
            guard !drawLine.isHiding else { continue }
            values.append(drawLine.points[selectionIndex].value)
            colors.append(drawLine.color)
            titles.append(drawLine.name)
        }
        return SelectionData(date: date, format: .weekdayDayMonthYear, values: values, colors: colors, titles: titles)
    }
    
    // MARK: Styles
    
    func themeDidUpdate(theme: Theme) {
        backColor = theme.cellBackgroundColor
        gridMainColor = theme.chartGridMainColor
        gridAuxColor = theme.chartGridAuxColor
        
        let attribs = [NSAttributedString.Key.foregroundColor: theme.chartTitlesColor]
        xDrawAxis.attributes = attribs
        xDrawAxis.attributes = attribs
        redraw()
    }
}
