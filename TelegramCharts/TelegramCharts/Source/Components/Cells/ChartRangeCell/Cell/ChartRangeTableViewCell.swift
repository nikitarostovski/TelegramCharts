//
//  ChartRangeTableViewCell.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartRangeTableViewCell: BaseTableViewCell {
    
    override class var cellHeight: CGFloat {
        return 68
    }
    
    @IBOutlet weak var chartView: ChartView! {
        didSet {
            chartView.lineWidth = 1.0
        }
    }
    @IBOutlet weak var rangeSlider: RangeSlider! {
        didSet {
            rangeSlider.delegate = self
        }
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartRangeTableViewCellModel else { return }
        chartView.charts = model.chartsData
        
        let insetTop = chartView.frame.minY - rangeSlider.frame.minY
        let insetBottom = rangeSlider.frame.maxY - chartView.frame.maxY
        rangeSlider.tintAreaInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: insetBottom, right: 0)
        rangeSlider.lowerValue = model.initialRange?.lowerBound ?? 0
        rangeSlider.upperValue = model.initialRange?.upperBound ?? 1
    }
}

extension ChartRangeTableViewCell: RangeSliderDelegate {

    func rangeDidChange(sender: RangeSlider) {
        guard let model = model as? ChartRangeTableViewCellModel,
            let low = sender.lowerValue,
            let up = sender.upperValue else {
            return
        }
        model.rangeChangeAction?(low ... up)
    }
}
