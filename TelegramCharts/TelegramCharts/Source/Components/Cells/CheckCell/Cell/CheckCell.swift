//
//  CheckCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class CheckCell: BaseCell {

    override class var cellHeight: CGFloat {
        return 44
    }
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagView.layer.cornerRadius = 3
        tagView.layer.masksToBounds = true
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? CheckCellModel else { return }
        if model.hasCheckmark {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
        model.topSeparatorStyle.inset = titleLabel.frame.origin.x
        model.bottomSeparatorStyle.inset = titleLabel.frame.origin.x
        titleLabel.text = model.titleText
        tagView.backgroundColor = model.tagColor
    }

    // MARK: - Stylable

    override func themeDidUpdate(theme: Theme) {
        super.themeDidUpdate(theme: theme)
        tintColor = theme.tintColor
        titleLabel.textColor = theme.cellTextColor
    }
}


