//
//  ButtonCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ButtonTouchUpInsideAction = () -> Void

class ButtonCellModel: BaseCellModel {

    override var cellIdentifier: String {
        return ButtonCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return ButtonCell.cellHeight
    }
    
    override init() {
        super.init()
        isTouchable = false
    }
    
    var buttonTitle: String = ""
    
    var buttonTouchUpInsideAction: ButtonTouchUpInsideAction?
}
