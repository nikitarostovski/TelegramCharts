//
//  ChartTableViewCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartTableViewCell: BaseTableViewCell {

    override class var cellHeight: CGFloat {
        return 272
    }
    
    @IBOutlet weak var chartView: ChartView! {
        didSet {
            chartView.lineWidth = 2.0
        }
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartTableViewCellModel else { return }
        chartView.charts = model.chartsData
        chartView.visibleRange = model.visibleRange
    }
}
