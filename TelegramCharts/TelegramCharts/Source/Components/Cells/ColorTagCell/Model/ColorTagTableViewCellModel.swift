//
//  ColorTagTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias CellTapAction = () -> Void

class ColorTagTableViewCellModel: BaseTableViewCellModel {

    override class var cellIdentifier: String {
        return ColorTagTableViewCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ColorTagTableViewCell.cellHeight
    }
    
    var titleText = ""
    var tagColor: UIColor = .clear
    var hasCheckmark = false
    var cellTapAction: CellTapAction?
}
