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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        fatalError("Should override BaseTableViewCell class")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    func setup(with model: BaseTableViewCellModel) {
        self.model = model
    }
    
    func updateAppearance() {
        
    }
}
