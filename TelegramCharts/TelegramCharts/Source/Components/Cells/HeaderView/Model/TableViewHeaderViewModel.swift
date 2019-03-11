//
//  TableViewHeaderViewModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class TableViewHeaderViewModel {

    var reuseIdentifier: String {
        return TableViewHeaderView.reuseIdentifier()
    }
    
    var cellHeight: CGFloat {
        return TableViewHeaderView.cellHeight
    }
    
    var titleText: String = ""
}
