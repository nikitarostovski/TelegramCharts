//
//  TableViewHeaderView.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class TableViewHeaderView: UITableViewHeaderFooterView {
    
    var theme: Theme? {
        didSet {
            updateAppearance()
        }
    }
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }
    
    private weak var model: TableViewHeaderViewModel?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(with model: TableViewHeaderViewModel) {
        self.model = model
        titleLabel.text = model.titleText
    }
    
    func updateAppearance() {
        guard let theme = theme else {
            return
        }
        titleLabel.textColor = theme.sectionTextColor
        titleLabel.backgroundColor = theme.backgroundColor
    }
}
