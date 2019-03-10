//
//  ButtonTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ButtonTableViewCellModel: BaseTableViewCellModel {

    override class var cellIdentifier: String {
        return ButtonTableViewCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ButtonTableViewCell.cellHeight
    }
}
