//
//  BaseTableViewCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

struct SeparatorStyle {
    var isHidden: Bool = true
    var inset: CGFloat = 0
    var clampToEdge = true
}

class BaseTableViewCellModel {
    
    class var cellIdentifier: String {
        return ""
    }
    
    func cellHeight() -> CGFloat {
        return 0
    }
    
    static func registerNib(for tableView: UITableView) {
        tableView.register(UINib(nibName: cellIdentifier, bundle: .main), forCellReuseIdentifier: cellIdentifier)
    }
    var topSeparatorStyle = SeparatorStyle()
    var bottomSeparatorStyle = SeparatorStyle()
}
