//
//  FilterCellModel.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class FilterCellModel: BaseCellModel {

    override var cellIdentifier: String {
        return FilterCell.cellIdentifier()
    }
    
    override func cellHeight() -> CGFloat {
        return FilterCell.cellHeight
    }
    
    var graphIndex: Int
    var graph: Graph
    
    init(graphIndex: Int, graph: Graph) {
        self.graph = graph
        self.graphIndex = graphIndex
        super.init()
        isTouchable = false
    }
}
