//
//  ChartDataSource.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 08/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ChartLine = (values: [Int], color: UIColor, name: String)

struct ChartSelectionData {
    var date: Date?
    var format: DateFormat?
    var values: [Int]
    var colors: [UIColor]
    var titles: [String]
}

class ChartLineData {
    private (set) var name: String
    private (set) var color: UIColor
    private (set) var points: [ChartPointData]
    var visible: Bool = true

    init(name: String, color: UIColor, points: [ChartPointData]) {
        self.name = name
        self.color = color

        self.points = points
    }
}

class ChartPointData {
    var index: Int
    var value: Int
    var x: CGFloat

    init(index: Int, value: Int) {
        self.index = index
        self.value = value
        self.x = 0
    }
}

class ChartDataSource {

    private (set) var range: ClosedRange<CGFloat>

    var maxVisibleLineIndex: Int
    var maxVisiblePointIndex: Int
    var lines: [ChartLineData]
    var dates: [Date]
    var xPositions: [CGFloat]

    var selectionIndex: Int?

    var xUpdateHandler: (() -> Void)?
    var yUpdateHandler: (() -> Void)?
    var alphaUpdateHandler: (() -> Void)?

    private var lo: Int
    private var hi: Int

    init(lines: [ChartLine], dates: [Date], range: ClosedRange<CGFloat>) {
        self.dates = dates
        self.range = range
        self.lines = [ChartLineData]()
        self.xPositions = dates.map { _ in 0 }
        for line in lines {
            var points = [ChartPointData]()
            for i in line.values.indices {
                points.append(ChartPointData(index: i, value: line.values[i]))
            }
            self.lines.append(ChartLineData(name: line.name, color: line.color, points: points))
        }
        self.lo = 0
        self.hi = dates.count - 1
        maxVisibleLineIndex = 0
        maxVisiblePointIndex = 0
        update()
    }

    private func update() {
        guard xPositions.count > 0 else { return }
        var newMaxVisibleValue = 0
        var newMaxVisiblePointIndex = 0
        var newMaxVisibleLineIndex = 0

        var loSet = false
        var hiSet = false
        for i in xPositions.indices {
            xPositions[i] = calcXForIndex(i: i, count: xPositions.count)
            if !loSet, xPositions[i] >= 0 {
                loSet = true
                lo = max(0, i - 1)
            }
            if !hiSet, loSet, xPositions[i] > 1 {
                hiSet = true
                hi = min(xPositions.count - 1, i + 1)
            }
        }
        for lnIndex in lines.indices {
            let line = lines[lnIndex]
            guard line.visible else { continue }
            for ptIndex in lo ... hi {
                if line.points[ptIndex].value > newMaxVisibleValue {
                    newMaxVisibleValue = line.points[ptIndex].value
                    newMaxVisibleLineIndex = lnIndex
                    newMaxVisiblePointIndex = ptIndex
                }
            }
        }
        if newMaxVisibleLineIndex != self.maxVisibleLineIndex || newMaxVisiblePointIndex != self.maxVisiblePointIndex {
            self.maxVisibleLineIndex = newMaxVisibleLineIndex
            self.maxVisiblePointIndex = newMaxVisiblePointIndex
            yUpdateHandler?()
        }
        xUpdateHandler?()
    }

    private func calcXForIndex(i: Int, count: Int) -> CGFloat {
        return (CGFloat(i) / CGFloat(count) - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

extension ChartDataSource: ChartDataSourceProtocol {

    var visibleIndices: [Int] {
        return Array(lo ... hi)
    }

    var maxVisibleValue: Int {
        return lines[maxVisibleLineIndex].points[maxVisiblePointIndex].value
    }

    var plateData: ChartSelectionData? {
        guard let selectionIndex = selectionIndex else { return nil }
        let date = dates[selectionIndex]
        var values = [Int]()
        var titles = [String]()
        var colors = [UIColor]()
        for line in lines {
            guard line.visible else { continue }
            values.append(line.points[selectionIndex].value)
            colors.append(line.color)
            titles.append(line.name)
        }
        return ChartSelectionData(date: date, format: .weekdayDayMonthYear, values: values, colors: colors, titles: titles)
    }

    func trySelect(x: CGFloat) {
        let index = 0
        selectionIndex = index
    }

    func setLineVisibility(index: Int, visible: Bool) {
        lines.forEach {
            $0.visible = visible
        }
        alphaUpdateHandler?()
        update()
    }

    func changeLowerBound(newLow: CGFloat) {
        self.range = newLow ... range.upperBound
        update()
//        xDrawAxis.changeLowerBound(newLow: newLow)
//        recalcVisibleIndices()
//        updateTolerance()
//        recalc()
    }

    func changeUpperBound(newUp: CGFloat) {
        self.range = range.lowerBound ... newUp
        update()
//        xDrawAxis.changeUpperBound(newUp: newUp)
//        recalcVisibleIndices()
//        recalc()
    }

    func changePoisition(newLow: CGFloat) {
        let diff = range.upperBound - range.lowerBound
        range = newLow ... newLow + diff
        update()
//        xDrawAxis.changePoisition(newLow: newLow)
//        recalcVisibleIndices()
//        hideSelection()
//        recalc()
    }
}
