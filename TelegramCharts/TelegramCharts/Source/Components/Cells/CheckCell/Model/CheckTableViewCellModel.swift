//
//  CheckTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias CellTapAction = () -> Void

class CheckTableViewCellModel: BaseTableViewCellModel {

    override var cellIdentifier: String {
        return CheckTableViewCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return CheckTableViewCell.cellHeight
    }
    
    var titleText = ""
    var tagColor: UIColor = .clear
    var hasCheckmark = false
    var cellTapAction: CellTapAction?
}
