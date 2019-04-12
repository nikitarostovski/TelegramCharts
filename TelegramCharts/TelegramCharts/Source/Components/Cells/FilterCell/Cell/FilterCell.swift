//
//  FilterCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class FilterCell: BaseCell {
    
    override class var cellHeight: CGFloat {
        return 46
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? FilterCellModel else { return }
        
    }

//    override func themeDidUpdate(theme: Theme) {
//        super.themeDidUpdate(theme: theme)
//        button.tintColor = theme.tintColor
//    }
}
