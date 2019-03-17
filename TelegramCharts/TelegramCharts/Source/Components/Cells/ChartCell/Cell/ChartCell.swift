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
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartCellModel else { return }
        
        if model.currentRange == nil {
            model.currentRange = 0 ... 1
        }
        currentRange = model.currentRange
        
        mainChartView.charts = model.chartsData
        mainChartView.axis = model.axisData
        mainChartView.grid = model.gridData
        mainChartView.visibleRange = currentRange!
        
        mapChartView.axis = nil
        mapChartView.grid = nil
        mapChartView.chartInsets = .zero
        mapChartView.charts = model.chartsData?.copy()
        mapChartView.visibleRange = 0 ... 1
        
        let insetTop = mapChartView.frame.minY - rangeSlider.frame.minY
        let insetBottom = rangeSlider.frame.maxY - mapChartView.frame.maxY
        rangeSlider.tintAreaInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: insetBottom, right: 0)
        rangeSlider.lowerValue = currentRange!.lowerBound
        rangeSlider.upperValue = currentRange!.upperBound
    }
}

extension ChartCell: RangeSliderDelegate {
    
    func rangeDidChange(sender: RangeSlider) {
        guard let low = sender.lowerValue,
            let up = sender.upperValue else {
                return
        }
        currentRange = low ... up
        mainChartView.visibleRange = currentRange!
        if let model = model as? ChartCellModel {
            model.currentRange = currentRange
        }
    }
}
