//
//  ChartCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartCellModel: BaseCellModel, ChartViewDataSource {

    var drawLines: [ChartDrawLine] = [ChartDrawLine]()
    var xDrawAxis: ChartDrawAxisX
    var yDrawAxis: ChartDrawAxisY
    var dateTextWidth: CGFloat
    var maxValue: Int
    var xAxisTextSpacing: CGFloat = 20

    var linesVisibility: [Bool]?
    var chartIndex: Int
    var currentRange: ClosedRange<CGFloat>

    override var cellIdentifier: String {
        return ChartCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ChartCell.cellHeight
    }
    
    init(chartIndex: Int, chartLines: [ChartLine], chartDates: [Date], currentRange: ClosedRange<CGFloat>) {
        self.chartIndex = chartIndex
        self.currentRange = currentRange
        maxValue = 0
        var newDrawLines = [ChartDrawLine]()
        linesVisibility = [Bool]()
        for line in chartLines {
            newDrawLines.append(ChartDrawLine(color: line.color, points: line.values))
            maxValue = max(maxValue, line.values.max() ?? 0)
            linesVisibility!.append(true)
        }
        self.drawLines = newDrawLines

        self.yDrawAxis = ChartDrawAxisY(maxValue: maxValue, attributes: [:])
        self.xDrawAxis = ChartDrawAxisX(dates: chartDates, attributes: [:], range: currentRange)

        dateTextWidth = 0
        for p in xDrawAxis.points {
            let width = p.title.width(withConstrainedHeight: .greatestFiniteMagnitude)
            dateTextWidth = max(dateTextWidth, width)
        }
        dateTextWidth += xAxisTextSpacing
        super.init()
        isTouchable = false
    }

    // styles
    private var titleColor: UIColor = .black
    private func makeYAxisTextAttributes() -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [
            .foregroundColor: titleColor,
            .paragraphStyle: style
        ]
    }
    private func makeXAxisTextAttributes() -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [
            .paragraphStyle: style,
            .foregroundColor: titleColor
        ]
    }
}

extension ChartCellModel: RangeSliderDelegate {

    func sliderLeftDidChange(sender: RangeSlider) {
        guard let cell = cell as? ChartCell else { return }
        if let newLow = sender.lowerValue {
            self.currentRange = newLow ... currentRange.upperBound
            xDrawAxis.changeLowerBound(newLow: newLow)
            cell.mainChartView.setRange(range: currentRange)
            cell.mainChartView.update()
        }
    }

    func sliderRightDidChange(sender: RangeSlider) {
        guard let cell = cell as? ChartCell else { return }
        if let newUp = sender.upperValue {
            self.currentRange = currentRange.lowerBound ... newUp
            xDrawAxis.changeUpperBound(newUp: newUp)
            cell.mainChartView.setRange(range: currentRange)
            cell.mainChartView.update()
        }
    }

    func sliderDidScroll(sender: RangeSlider) {
        guard let cell = cell as? ChartCell else { return }
        if let newLow = sender.lowerValue {
            let diff = currentRange.upperBound - currentRange.lowerBound
            currentRange = newLow ... newLow + diff
            xDrawAxis.changePoisition(newLow: newLow)
            cell.mainChartView.hideSelection()
            cell.mainChartView.setRange(range: currentRange)
            cell.mainChartView.update()
        }
    }
}
