//
//  ButtonTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ButtonTouchUpInsideAction = () -> Void

class ButtonTableViewCellModel: BaseTableViewCellModel {

    override var cellIdentifier: String {
        return ButtonTableViewCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ButtonTableViewCell.cellHeight
    }
    
    var buttonTitle: String = ""
    
    var buttonTouchUpInsideAction: ButtonTouchUpInsideAction?
}
