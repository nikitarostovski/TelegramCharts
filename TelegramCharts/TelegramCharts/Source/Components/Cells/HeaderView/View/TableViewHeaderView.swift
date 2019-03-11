//
//  TableViewHeaderView.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class TableViewHeaderView: UITableViewHeaderFooterView, Stylable {

    static func reuseIdentifier() -> String {
        return String(describing: self)
    }
    class var cellHeight: CGFloat {
        return 44
    }
    
    private weak var model: TableViewHeaderViewModel?
    
    @IBOutlet weak var bacKView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        startReceivingThemeUpdates()
    }

    deinit {
        stopReceivingThemeUpdates()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearance()
    }
    
    func setup(with model: TableViewHeaderViewModel) {
        self.model = model
        updateAppearance()
    }
    
    func updateAppearance() {
        guard let model = model else {
            return
        }
        titleLabel.text = model.titleText
    }

    func themeDidUpdate(theme: Theme) {
        bacKView.backgroundColor = theme.viewBackgroundColor
        titleLabel.textColor = theme.sectionTextColor
    }
}
