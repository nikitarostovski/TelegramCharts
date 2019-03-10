//
//  ButtonTableViewCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ButtonTableViewCell: BaseTableViewCell {

    @IBOutlet weak var button: UIButton!
    
    override class var cellHeight: CGFloat {
        return 46
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setup(with model: BaseTableViewCellModel) {
        super.setup(with: model)
        updateAppearance()
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let theme = theme,
            let model = model as? ButtonTableViewCellModel else {
            return
        }
        button.setTitle(model.buttonTitle, for: .normal)
        button.tintColor = theme.tintColor
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        guard let model = model as? ButtonTableViewCellModel else {
            return
        }
        model.buttonTouchUpInsideAction?()
    }
}
