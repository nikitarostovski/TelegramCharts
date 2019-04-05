//
//  BaseCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias CellTapAction = (BaseCellModel, BaseCell) -> Void

struct SeparatorStyle {
    var isHidden: Bool = true
    var inset: CGFloat = 0
    var clampToEdge = true
}

class BaseCellModel {

    weak var cell: BaseCell?

    var cellIdentifier: String {
        return ""
    }
    
    func cellHeight() -> CGFloat {
        return 0
    }
    
    var topSeparatorStyle = SeparatorStyle()
    var bottomSeparatorStyle = SeparatorStyle()
    var cellTapAction: CellTapAction?
    var isTouchable = true
}
