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
    
    private var topSeparatorLayer: CALayer?
    
    override class var cellHeight: CGFloat {
        return 44
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = .zero
        topSeparatorLayer?.removeFromSuperlayer()
        topSeparatorLayer = CALayer()
        layer.addSublayer(topSeparatorLayer!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = 1.0 / UIScreen.main.scale
        topSeparatorLayer?.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: height)
    }

    override func setup(with model: BaseTableViewCellModel) {
        guard let model = model as? ButtonTableViewCellModel else {
            return
        }
        super.setup(with: model)
        button.setTitle(model.buttonTitle, for: .normal)
    }
    
    override func updateAppearance() {
        guard let theme = theme else {
            return
        }
        button.tintColor = theme.tintColor
        topSeparatorLayer?.backgroundColor = theme.tableSeparatorColor.cgColor
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        guard let model = model as? ButtonTableViewCellModel else {
            return
        }
        model.buttonTouchUpInsideAction?()
    }
}
