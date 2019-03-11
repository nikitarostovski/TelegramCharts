//
//  RangeTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class RangeTableViewCellModel: BaseTableViewCellModel {
    
    override var cellIdentifier: String {
        return RangeTableViewCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return RangeTableViewCell.cellHeight
    }
}
