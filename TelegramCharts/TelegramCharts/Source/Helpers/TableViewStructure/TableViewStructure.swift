//
//  TableViewStructure.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

struct TableViewSection {
    var headerModel: TableViewHeaderViewModel?
    var cellModels: [BaseTableViewCellModel]
}

class TableViewStructure {
    
    var sections = [TableViewSection]()
    
    func clear() {
        sections = [TableViewSection]()
    }
    
    func addSection(section: TableViewSection) {
        sections.append(section)
    }
    
    func cellModel(for indexPath: IndexPath) -> BaseTableViewCellModel {
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        let section = sections[sectionIndex]
        return section.cellModels[rowIndex]
    }
}
