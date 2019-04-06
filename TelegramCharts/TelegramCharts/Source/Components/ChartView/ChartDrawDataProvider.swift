//
//  ChartDrawDataProvider.swift
//  TelegramCharts
//
//  Created by Rost on 05/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawDataProvider: NSObject, ChartViewDataSource {
    
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
    
    var redrawHandler: (() -> Void)?
    var hideSelectionHandler: (() -> Void)?
    
    private var fadeAnimator = Animator()
    private var xAnimator = Animator()
    private var yAnimator = Animator()
    
    init(lines: [ChartLine], dates: [Date], range: ClosedRange<CGFloat>) {
        self.maxValue = 0
        self.range = range
        self.drawLines = [ChartDrawLine]()
        self.linesVisibility = [Bool]()
        for line in lines {
            drawLines.append(ChartDrawLine(color: line.color, points: line.values))
            maxValue = max(maxValue, line.values.max() ?? 0)
            linesVisibility!.append(true)
        }
        maxVisibleValue = maxValue
        maxVisibleY = 0
        maxTotalVisibleY = 0
        targetMaxVisibleY = 0
        targetMaxTotalVisibleY = 0
        
        self.xDrawAxis = ChartDrawAxisX(dates: dates, attributes: [:], range: range)
        self.yDrawAxis = ChartDrawAxisY(maxValue: maxValue, attributes: [:])
        
        dateTextWidth = 0
        for p in xDrawAxis.points {
            let width = p.title.width(withConstrainedHeight: .greatestFiniteMagnitude)
            dateTextWidth = max(dateTextWidth, width)
        }
        dateTextWidth += xAxisTextSpacing
        
        super.init()
        self.updateYAxisDrawPositions()
        self.startReceivingThemeUpdates()
        
        recalc(animated: false)
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    func viewSizeChanged(newSize: CGSize) {
        xDrawAxis.changeTextWidth(newWidth: dateTextWidth / newSize.width)
    }
    
    func setLineVisibility(index: Int, visible: Bool, animated: Bool = true) {
        let line = drawLines[index]
        if line.isHiding == visible {
            line.isHiding = !visible
        }
        recalc()
//        if !plate.isHidden, let data = getChartCurrentData() {
//            plate.update(date: data.0, numbers: data.1)
//        }
        let transitionHandler: (CGFloat) -> Void = { [weak self] phase in
            guard let self = self else { return }
            for drawLine in self.drawLines {
                drawLine.alpha = drawLine.alpha + (drawLine.targetAlpha - drawLine.alpha) * phase
            }
            self.redraw()
        }
        if animated {
            fadeAnimator.animate(duration: 1, update: transitionHandler)
        } else {
            transitionHandler(1)
        }
    }
    
    func changeLowerBound(newLow: CGFloat) {
        self.range = newLow ... range.upperBound
        xDrawAxis.changeLowerBound(newLow: newLow)
        recalc()
    }
    
    func changeUpperBound(newUp: CGFloat) {
        self.range = range.lowerBound ... newUp
        xDrawAxis.changeUpperBound(newUp: newUp)
        recalc()
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        xDrawAxis.changePoisition(newLow: newLow)
        hideSelection()
        recalc()
    }
    
    // MARK: - Private
    
    private func redraw() {
        redrawHandler?()
    }
    
    private func hideSelection() {
        hideSelectionHandler?()
    }
    
    private func recalc(animated: Bool = true) {
        var newMaxVisibleValue = 0
        var newTotalMaxVisibleValue = 0
        
        for i in drawLines.indices {
            let drawLine = drawLines[i]
            if !drawLine.isHiding {
                newTotalMaxVisibleValue = max(newTotalMaxVisibleValue, drawLine.maxValue)
            }
            drawLine.firstIndex = xDrawAxis.firstIndex
            drawLine.lastIndex = xDrawAxis.lastIndex
            if !drawLine.isHiding {
                for j in drawLine.firstIndex ... drawLine.lastIndex {
                    drawLine.points[j].x = xDrawAxis.points[j].x
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
        let updateHandler: (CGFloat) -> Void = { [weak self] phase in
            guard let self = self else { return }
            self.maxVisibleY = self.maxVisibleY + (self.targetMaxVisibleY - self.maxVisibleY) * phase
            self.maxTotalVisibleY = self.maxTotalVisibleY + (self.targetMaxTotalVisibleY - self.maxTotalVisibleY) * phase
                for pt in self.yDrawAxis.hidingPoints {
                    pt.alpha = pt.alpha - pt.alpha * phase
                }
                for pt in self.yDrawAxis.points {
                    pt.alpha = pt.alpha + (1 - pt.alpha) * phase
                }
            self.redraw()
        }
        if animated {
            yAnimator.animate(duration: 2.0, easing: .linear, update: updateHandler, finish: nil)
        } else {
            updateHandler(1)
        }
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
        let updateHandler: (CGFloat) -> Void = { [weak self] phase in
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
        }
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
