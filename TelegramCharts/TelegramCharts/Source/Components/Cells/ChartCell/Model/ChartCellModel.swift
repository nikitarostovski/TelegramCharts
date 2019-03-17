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
    
    var chartsData: ChartsData?
    var axisData: AxisData?
    var gridData: GridData?
    var currentRange: ClosedRange<CGFloat>?
}
