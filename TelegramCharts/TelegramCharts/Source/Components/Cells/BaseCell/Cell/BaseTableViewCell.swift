//
//  BaseTableViewCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell, Stylable {

    weak var model: BaseTableViewCellModel?
    
    class var cellHeight: CGFloat {
        return 44
    }
    
    private var topSeparatorLayer: CALayer?
    private var bottomSeparatorLayer: CALayer?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        fatalError("Should override BaseTableViewCell class")
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
    
    func setup(with model: BaseTableViewCellModel) {
        self.model = model
        updateAppearance()
    }
    
    func updateAppearance() {
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

    // MARK: - Stylable

    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
        topSeparatorLayer?.backgroundColor = theme.tableSeparatorColor.cgColor
        bottomSeparatorLayer?.backgroundColor = theme.tableSeparatorColor.cgColor
    }
}
