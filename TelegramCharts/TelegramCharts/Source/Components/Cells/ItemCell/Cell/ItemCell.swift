//
//  ItemCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ItemCell: BaseCell {

    override class var cellHeight: CGFloat {
        return 44
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? ItemCellModel else { return }
        model.topSeparatorStyle.inset = titleLabel.frame.origin.x
        model.bottomSeparatorStyle.inset = titleLabel.frame.origin.x
        titleLabel.text = model.titleText
    }

    // MARK: - Stylable

    override func themeDidUpdate(theme: Theme) {
        super.themeDidUpdate(theme: theme)
        tintColor = theme.tintColor
        titleLabel.textColor = theme.cellTextColor
    }
}


