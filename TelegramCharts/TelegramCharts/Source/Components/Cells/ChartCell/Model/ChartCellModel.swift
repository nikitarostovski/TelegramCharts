//
//  ChartCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartCellModel: BaseCellModel {

    var dataProvider: ChartDataSourceProtocol
    var chartIndex: Int

    override var cellIdentifier: String {
        return ChartCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ChartCell.cellHeight
    }
    
    init(chartIndex: Int, chartLines: [ChartLine], chartDates: [Date], currentRange: ClosedRange<CGFloat>) {
        self.chartIndex = chartIndex
        self.dataProvider = ChartDataSource(lines: chartLines, dates: chartDates, range: currentRange)
        super.init()
        isTouchable = false
    }
    
    func setLineVisibility(index: Int, visible: Bool) {
//        dataProvider.setLineVisibility(index: index, visible: visible)
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
        if let newLow = sender.lowerValue {
            dataProvider.changeLowerBound(newLow: newLow)
        }
    }

    func sliderRightDidChange(sender: RangeSlider) {
        if let newUp = sender.upperValue {
            dataProvider.changeUpperBound(newUp: newUp)
        }
    }

    func sliderDidScroll(sender: RangeSlider) {
        if let newLow = sender.lowerValue {
            dataProvider.changePoisition(newLow: newLow)
        }
    }
}
