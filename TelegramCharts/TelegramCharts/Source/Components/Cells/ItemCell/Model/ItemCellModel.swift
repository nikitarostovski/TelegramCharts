//
//  CheckCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ItemCellTapAction = () -> Void

class ItemCellModel: BaseCellModel {

    override var cellIdentifier: String {
        return ItemCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ItemCell.cellHeight
    }
    
    var titleText = ""
    var cellTapAction: ItemCellTapAction?
}
