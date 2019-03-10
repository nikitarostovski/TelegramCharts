//
//  ColorTagTableViewCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ColorTagTableViewCell: BaseTableViewCell {

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
    
    override func setup(with model: BaseTableViewCellModel) {
        super.setup(with: model)
        updateAppearance()
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let theme = theme,
            let model = model as? ColorTagTableViewCellModel else {
                return
        }
        if model.hasCheckmark {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
        model.topSeparatorStyle.inset = titleLabel.frame.origin.x
        model.bottomSeparatorStyle.inset = titleLabel.frame.origin.x
        tintColor = theme.tintColor
        titleLabel.text = model.titleText
        tagView.backgroundColor = model.tagColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        guard let model = model as? ColorTagTableViewCellModel else {
            return
        }
        super.setSelected(selected, animated: animated)
        model.hasCheckmark = selected
        updateAppearance()
        model.cellTapAction?()
    }
}
