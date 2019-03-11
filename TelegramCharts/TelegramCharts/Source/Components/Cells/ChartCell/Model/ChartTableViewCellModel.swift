//
//  ChartTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartTableViewCellModel: BaseTableViewCellModel {

    override var cellIdentifier: String {
        return ChartTableViewCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ChartTableViewCell.cellHeight
    }
    
    var chartData = [ChartData]()
}
