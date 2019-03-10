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
    
    private var highlightLayer = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagView.layer.cornerRadius = 3
        tagView.layer.masksToBounds = true
        selectionStyle = .none
        
        highlightLayer.removeFromSuperlayer()
        highlightLayer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
        highlightLayer.opacity = 0.0
        layer.addSublayer(highlightLayer)
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
        highlightLayer.frame = bounds
        if model.hasCheckmark {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
        model.topSeparatorStyle.inset = titleLabel.frame.origin.x
        model.bottomSeparatorStyle.inset = titleLabel.frame.origin.x
        tintColor = theme.tintColor
        titleLabel.text = model.titleText
        titleLabel.textColor = theme.cellTextColor
        tagView.backgroundColor = model.tagColor
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlightOn()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlightOff()
        guard let model = model as? ColorTagTableViewCellModel else { return }
        model.hasCheckmark = !model.hasCheckmark
        updateAppearance()
        model.cellTapAction?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlightOff()
    }
    
    // MARK: - Highlight animation
    
    private func highlightOn() {
        let newOpacity: Float = 1
        highlightLayer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = highlightLayer.opacity
        animation.toValue = newOpacity
        animation.duration = 0.1
        animation.autoreverses = false
        highlightLayer.opacity = newOpacity
        highlightLayer.add(animation, forKey: "opacityOn")
    }
    
    private func highlightOff() {
        let newOpacity: Float = 0
        highlightLayer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = highlightLayer.opacity
        animation.toValue = newOpacity
        animation.duration = 0.1
        animation.autoreverses = false
        highlightLayer.opacity = newOpacity
        highlightLayer.add(animation, forKey: "opacityOff")
    }
}
