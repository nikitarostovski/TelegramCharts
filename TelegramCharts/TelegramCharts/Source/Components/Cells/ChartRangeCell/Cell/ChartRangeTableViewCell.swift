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
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartRangeTableViewCellModel else { return }
        chartView.charts = model.chartData
    }
}
