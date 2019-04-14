//
//  FilterCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class FilterCell: BaseCell {
    
    @IBOutlet weak var container: FilterButtonContainer!
    override class var cellHeight: CGFloat {
        return UITableView.automaticDimension
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? FilterCellModel else { return }
        
        var buttons = [UIButton]()
        for m in model.graph.charts {
            let b = UIButton(type: .system)
            b.setTitle(m.name, for: .normal)
            b.backgroundColor = m.color
            b.tintColor = .white
            buttons.append(b)
        }
        container.buttons = buttons
        container.setNeedsLayout()
        container.layoutIfNeeded()
    }
}
