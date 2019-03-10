//
//  BaseTableViewCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var theme: Theme? {
        didSet {
            updateAppearance()
        }
    }
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
        topSeparatorLayer?.removeFromSuperlayer()
        topSeparatorLayer = CALayer()
        layer.addSublayer(topSeparatorLayer!)
        bottomSeparatorLayer?.removeFromSuperlayer()
        bottomSeparatorLayer = CALayer()
        layer.addSublayer(bottomSeparatorLayer!)
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
    }
    
    func updateAppearance() {
        guard let theme = theme,
            let model = model else {
            return
        }
        topSeparatorLayer?.backgroundColor = theme.tableSeparatorColor.cgColor
        bottomSeparatorLayer?.backgroundColor = theme.tableSeparatorColor.cgColor
        
        topSeparatorLayer?.isHidden = model.topSeparatorHidden
        bottomSeparatorLayer?.isHidden = model.bottomSeparatorHidden
        
        let height = 1.0 / UIScreen.main.scale
        let topInset = model.topSeparatorInset
        let bottomInset = model.bottomSeparatorInset
        topSeparatorLayer?.frame = CGRect(x: topInset,
                                          y: 0.0,
                                          width: frame.size.width - topInset,
                                          height: height)
        bottomSeparatorLayer?.frame = CGRect(x: bottomInset,
                                             y: frame.size.height - height,
                                             width: frame.size.width - bottomInset,
                                             height: height)
    }
}
