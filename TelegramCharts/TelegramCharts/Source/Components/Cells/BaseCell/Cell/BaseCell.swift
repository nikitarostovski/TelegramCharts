//
//  BaseCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell, Stylable {

    weak var model: BaseCellModel?
    
    class var cellHeight: CGFloat {
        return 44
    }
    
    private var highlightLayer = CALayer()
    private var topSeparatorLayer: CALayer?
    private var bottomSeparatorLayer: CALayer?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        fatalError("Should override BaseCell class")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        topSeparatorLayer?.removeFromSuperlayer()
        topSeparatorLayer = CALayer()
        layer.addSublayer(topSeparatorLayer!)
        bottomSeparatorLayer?.removeFromSuperlayer()
        bottomSeparatorLayer = CALayer()
        layer.addSublayer(bottomSeparatorLayer!)
        highlightLayer.removeFromSuperlayer()
        highlightLayer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
        highlightLayer.opacity = 0.0
        layer.addSublayer(highlightLayer)
        startReceivingThemeUpdates()
    }

    deinit {
        stopReceivingThemeUpdates()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearance()
    }
    
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    func setup(with model: BaseCellModel) {
        self.model = model
        updateAppearance()
    }
    
    func updateAppearance() {
        highlightLayer.frame = bounds
        guard let model = model else { return }

        topSeparatorLayer?.isHidden = model.topSeparatorStyle.isHidden
        bottomSeparatorLayer?.isHidden = model.bottomSeparatorStyle.isHidden
        
        let height = 1.0 / UIScreen.main.scale
        let topInset = model.topSeparatorStyle.clampToEdge ? 0 : model.topSeparatorStyle.inset
        let bottomInset = model.bottomSeparatorStyle.clampToEdge ? 0 : model.bottomSeparatorStyle.inset
        topSeparatorLayer?.frame = CGRect(x: topInset,
                                          y: 0.0,
                                          width: frame.size.width - topInset,
                                          height: height)
        bottomSeparatorLayer?.frame = CGRect(x: bottomInset,
                                             y: frame.size.height - height,
                                             width: frame.size.width - bottomInset,
                                             height: height)
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard model?.isTouchable ?? false else { return }
        highlightOn()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard model?.isTouchable ?? false else { return }
        highlightOff()
        guard let model = model as? ItemCellModel else { return }
        updateAppearance()
        model.cellTapAction?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard model?.isTouchable ?? false else { return }
        highlightOff()
    }
    
    // MARK: - Highlight animation
    
    private func highlightOn() {
        let newOpacity: Float = 1
        highlightLayer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = highlightLayer.opacity
        animation.toValue = newOpacity
        animation.duration = 0.01
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
        animation.duration = 0.01
        animation.autoreverses = false
        highlightLayer.opacity = newOpacity
        highlightLayer.add(animation, forKey: "opacityOff")
    }

    // MARK: - Stylable

    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
        topSeparatorLayer?.backgroundColor = theme.tableSeparatorColor.cgColor
        bottomSeparatorLayer?.backgroundColor = theme.tableSeparatorColor.cgColor
    }
}
