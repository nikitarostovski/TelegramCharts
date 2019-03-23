//
//  ChartCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartCell: BaseCell {

    override class var cellHeight: CGFloat {
        return 340
    }
    
    @IBOutlet weak var mainChartView: ChartView! {
        didSet {
            mainChartView.lineWidth = 2.0
        }
    }
    
    @IBOutlet weak var mapChartView: ChartView! {
        didSet {
            mapChartView.lineWidth = 1.0
        }
    }
    @IBOutlet weak var rangeSlider: RangeSlider! {
        didSet {
            rangeSlider.delegate = self
        }
    }
    
    private var currentRange: ClosedRange<CGFloat>?
    
    func updateLinesVisibility() {
        guard let model = model as? ChartCellModel, let visibility = model.linesVisibility else { return }
        mainChartView.setLinesVisibility(visibility: visibility)
        mapChartView.setLinesVisibility(visibility: visibility)
    }
    
    private var chartDataIsSet = false
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartCellModel,
            let chartLines = model.chartLines,
            let chartDates = model.chartDates
        else {
            return
        }
        if model.currentRange == nil {
            model.currentRange = 0 ... 1
        }
        currentRange = model.currentRange

        if !chartDataIsSet {
            mainChartView.setupData(lines: chartLines, dates: chartDates)
            mainChartView.xRange = currentRange!
            mainChartView.changeLowerBound(newLow: currentRange!.lowerBound)
            
            mapChartView.setupData(lines: chartLines, dates: chartDates)
            mapChartView.gridVisible = false
            mapChartView.chartInsets = .zero
            mapChartView.xRange = 0 ... 1
            mapChartView.changeLowerBound(newLow: 0)
            
            if let visibility = model.linesVisibility {
                mainChartView.setLinesVisibility(visibility: visibility)
                mapChartView.setLinesVisibility(visibility: visibility)
            }
        }
        let insetTop = mapChartView.frame.minY - rangeSlider.frame.minY
        let insetBottom = rangeSlider.frame.maxY - mapChartView.frame.maxY
        rangeSlider.tintAreaInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: insetBottom, right: 0)
        rangeSlider.lowerValue = currentRange!.lowerBound
        rangeSlider.upperValue = currentRange!.upperBound
    }
}

extension ChartCell: RangeSliderDelegate {
    
    func sliderLeftDidChange(sender: RangeSlider) {
        guard let model = model as? ChartCellModel, let currentRange = currentRange else { return }
        if let newLow = sender.lowerValue {
            self.currentRange = newLow ... currentRange.upperBound
            model.currentRange = currentRange
            mainChartView.changeLowerBound(newLow: newLow)
        }
    }
    
    func sliderRightDidChange(sender: RangeSlider) {
        guard let model = model as? ChartCellModel, let currentRange = currentRange else { return }
        if let newUp = sender.upperValue {
            self.currentRange = currentRange.lowerBound ... newUp
            model.currentRange = currentRange
            mainChartView.changeUpperBound(newUp: newUp)
        }
    }
    
    func sliderDidScroll(sender: RangeSlider) {
        guard let model = model as? ChartCellModel else { return }
        if let newLow = sender.lowerValue, let newUp = sender.upperValue {
            currentRange = newLow ... newUp
            model.currentRange = currentRange
            mainChartView.changePoisition(newLow: newLow)
        }
    }
}
