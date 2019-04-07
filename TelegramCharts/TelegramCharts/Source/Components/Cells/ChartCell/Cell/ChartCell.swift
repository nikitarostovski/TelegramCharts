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
    
//    var mainChartView: ChartView!
//    var mapChartView: ChartView!

    var mainChartView: ChartComplexView!
    var mapChartView: ChartComplexView!
    
    var rangeSlider: RangeSlider!

    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartCellModel else { return }
        createViews()
        
        model.dataProvider.redrawHandler = { [weak self] in
            self?.mainChartView.updateChartPositions()
        }
        model.dataProvider.mapRedrawHandler = { [weak self] in
            self?.mapChartView.updateChartPositions()
        }
        model.dataProvider.updateAlphaHandler = { [weak self] in
            self?.mainChartView.updateChartAlpha()
            self?.mapChartView.updateChartAlpha()
        }
        
//        model.dataProvider.hideSelectionHandler = { [weak self] in
//            self?.mainChartView.hideSelection()
//        }
//        model.dataProvider.updateSelectionHandler = { [weak self] in
//            self?.mainChartView.moveSelection(animated: true)
//        }
        
        rangeSlider.lowerValue = model.dataProvider.range.lowerBound
        rangeSlider.upperValue = model.dataProvider.range.upperBound
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }

    private func createViews() {
        guard let model = model as? ChartCellModel else { return }
        if mainChartView != nil {
            mainChartView.removeFromSuperview()
        }
        if mapChartView != nil {
            mapChartView.removeFromSuperview()
        }
        if rangeSlider != nil {
            rangeSlider.removeFromSuperview()
        }
        let dataSource = model.dataProvider as ChartDataSource
        mainChartView = ChartComplexView(dataSource: dataSource, lineWidth: 2.0, isMap: false)
        mapChartView = ChartComplexView(dataSource: dataSource, lineWidth: 1.0, isMap: true)
//        mapChartView.chartInsets = .zero
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

        mainChartView.setNeedsDisplay()
        mapChartView.setNeedsDisplay()
    }
}
