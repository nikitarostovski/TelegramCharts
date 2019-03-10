//
//  TableViewHeaderViewModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class TableViewHeaderViewModel {

    class var reuseIdentifier: String {
        return TableViewHeaderView.reuseIdentifier()
    }
    
    class var cellHeight: CGFloat {
        return TableViewHeaderView.cellHeight
    }
    
    static func registerNib(for tableView: UITableView) {
        tableView.register(UINib(nibName: reuseIdentifier, bundle: .main),
                           forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
    
    var titleText: String = ""
}
