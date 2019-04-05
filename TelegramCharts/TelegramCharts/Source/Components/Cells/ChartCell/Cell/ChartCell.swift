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
    
    var mainChartView: ChartView!
    var mapChartView: ChartView!

    var rangeSlider: RangeSlider!
    
    private var currentRange: ClosedRange<CGFloat>?
    
    func updateLinesVisibility() {
        guard let model = model as? ChartCellModel, let visibility = model.linesVisibility else { return }
        mainChartView.setLinesVisibility(visibility: visibility)
        mapChartView.setLinesVisibility(visibility: visibility)
    }

    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartCellModel else { return }
        currentRange = model.currentRange

        createViews()

        if let visibility = model.linesVisibility {
            mainChartView.setLinesVisibility(visibility: visibility)
            mapChartView.setLinesVisibility(visibility: visibility)
        }

        rangeSlider.lowerValue = currentRange!.lowerBound
        rangeSlider.upperValue = currentRange!.upperBound
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }

    private func createViews() {
        if mainChartView != nil {
            mainChartView.removeFromSuperview()
        }
        if mapChartView != nil {
            mapChartView.removeFromSuperview()
        }
        if rangeSlider != nil {
            rangeSlider.removeFromSuperview()
        }
        mainChartView = ChartView(frame: .zero, dataSource: self.model as! ChartViewDataSource, range: currentRange!, lineWidth: 2.0, gridVisible: true)
        mapChartView = ChartView(frame: .zero, dataSource: self.model as! ChartViewDataSource, range: 0 ... 1, lineWidth: 1.0, gridVisible: false)
        mapChartView.chartInsets = .zero
        addSubview(mapChartView)
        addSubview(mainChartView)

        rangeSlider = RangeSlider(frame: .zero)
        rangeSlider.delegate = self.model as? RangeSliderDelegate
        addSubview(rangeSlider)
    }

    private func updateFrames() {
        let mapHeight: CGFloat = 36
        let mapFrame = CGRect(x: 16, y: bounds.height - mapHeight - 16, width: bounds.width - 32, height: mapHeight)
        let mainFrame = CGRect(x: 16, y: 0, width: bounds.width - 32, height: mapFrame.minY - 16)
        let sliderFrame = mapFrame.inset(by: UIEdgeInsets(top: -4, left: 0, bottom: -4, right: 0))

        mainChartView.frame = mainFrame
        mapChartView.frame = mapFrame
        rangeSlider.frame = sliderFrame

        let insetTop = mapChartView.frame.minY - rangeSlider.frame.minY
        let insetBottom = rangeSlider.frame.maxY - mapChartView.frame.maxY
        rangeSlider.tintAreaInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: insetBottom, right: 0)

        mainChartView.update(animated: false)
        mapChartView.update(animated: false)
    }
}
