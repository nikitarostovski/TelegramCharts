//
//  GraphDataSource.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 08/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

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

class GraphDataSource {

    private (set) var range: ClosedRange<CGFloat>

    var maxVisibleLineIndex: Int
    var maxVisiblePointIndex: Int
    var charts: [ChartLineData]
    var dates: [Date]
    var xPositions: [CGFloat]

    var selectionIndex: Int?

    var xUpdateHandler: (() -> Void)?
    var yUpdateHandler: (() -> Void)?
    var alphaUpdateHandler: (() -> Void)?

    private var lo: Int
    private var hi: Int

    init(graph: Graph, range: ClosedRange<CGFloat>) {
        self.dates = graph.dates
        self.range = range
        self.charts = [ChartLineData]()
        self.xPositions = dates.map { _ in 0 }
        for chart in graph.charts {
            var points = [ChartPointData]()
            for i in chart.values.indices {
                points.append(ChartPointData(index: i, value: chart.values[i]))
            }
            self.charts.append(ChartLineData(name: chart.name, color: chart.color, points: points))
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
        var newMaxVisibleChartIndex = 0

        var newLo = 0
        var newHi = xPositions.count - 1
        for i in xPositions.indices {
            xPositions[i] = calcXForIndex(i: i, count: xPositions.count)
            if i > 0, xPositions[i] >= 0, xPositions[i - 1] < 0 {
                newLo = i - 1
            }
            if i < xPositions.count - 1, xPositions[i] <= 1, xPositions[i + 1] > 1 {
                newHi = i + 1
            }
        }
        lo = newLo
        hi = newHi
        for chIndex in charts.indices {
            let chart = charts[chIndex]
            guard chart.visible else { continue }
            for ptIndex in lo ... hi {
                if chart.points[ptIndex].value > newMaxVisibleValue {
                    newMaxVisibleValue = chart.points[ptIndex].value
                    newMaxVisibleChartIndex = chIndex
                    newMaxVisiblePointIndex = ptIndex
                }
            }
        }
        if newMaxVisibleChartIndex != self.maxVisibleLineIndex || newMaxVisiblePointIndex != self.maxVisiblePointIndex {
            self.maxVisibleLineIndex = newMaxVisibleChartIndex
            self.maxVisiblePointIndex = newMaxVisiblePointIndex
            yUpdateHandler?()
        }
        xUpdateHandler?()
    }

    private func calcXForIndex(i: Int, count: Int) -> CGFloat {
        return (CGFloat(i) / CGFloat(count - 1) - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

extension GraphDataSource: GraphDataSourceProtocol {

    var visibleIndices: [Int] {
        return Array(lo ... hi)
    }

    var maxVisibleValue: Int {
        return charts[maxVisibleLineIndex].points[maxVisiblePointIndex].value
    }

    var plateData: ChartSelectionData? {
        guard let selectionIndex = selectionIndex else { return nil }
        let date = dates[selectionIndex]
        var values = [Int]()
        var titles = [String]()
        var colors = [UIColor]()
        for chart in charts {
            guard chart.visible else { continue }
            values.append(chart.points[selectionIndex].value)
            colors.append(chart.color)
            titles.append(chart.name)
        }
        return ChartSelectionData(date: date, format: .weekdayDayMonthYear, values: values, colors: colors, titles: titles)
    }

    func trySelect(x: CGFloat) {
        let index = 0
        selectionIndex = index
    }

    func setLineVisibility(index: Int, visible: Bool) {
        charts.forEach {
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
