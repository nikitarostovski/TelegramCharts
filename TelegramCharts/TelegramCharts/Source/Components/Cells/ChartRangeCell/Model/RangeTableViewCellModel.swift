//
//  ChartRangeTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias RangeChangeAction = (ClosedRange<CGFloat>) -> Void

class ChartRangeTableViewCellModel: BaseTableViewCellModel {
    
    override var cellIdentifier: String {
        return ChartRangeTableViewCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ChartRangeTableViewCell.cellHeight
    }
    
    var chartData = [ChartData]()
    var rangeChangeAction: RangeChangeAction?
}
