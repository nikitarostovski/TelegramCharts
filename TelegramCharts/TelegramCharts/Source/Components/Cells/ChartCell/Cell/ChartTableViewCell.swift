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
        return 273
    }
    
    @IBOutlet weak var chartView: ChartView!
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ChartTableViewCellModel else { return }
        chartView.charts = model.chartData
    }
}
