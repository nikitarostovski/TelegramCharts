//
//  ChartCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartCellModel: BaseCellModel {

    override var cellIdentifier: String {
        return ChartCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ChartCell.cellHeight
    }
    
    override init() {
        super.init()
        isTouchable = false
    }

    var chartLines: [ChartLine]?
    var chartGrid: ChartGrid?
    var currentRange: ClosedRange<CGFloat>?
}
