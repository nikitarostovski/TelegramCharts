//
//  UITableView+Structure.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

extension UITableView {

    func numberOfSections(in structure: TableViewStructure) -> NSInteger {
        return structure.sections.count
    }

    func numberOfRows(in structure: TableViewStructure, section: NSInteger) -> NSInteger {
        guard section >= 0 && section < structure.sections.count else {
            return 0
        }
        return structure.sections[section].cellModels.count
    }

    func dequeueReusableCell(with structure:TableViewStructure, indexPath: IndexPath) -> BaseTableViewCell {
        let model = structure.cellModel(for: indexPath)
        var cell: BaseTableViewCell? = dequeueReusableCell(withIdentifier: model.cellIdentifier) as? BaseTableViewCell
        if cell == nil {
            let nib = UINib(nibName: model.cellIdentifier, bundle: .main)
            register(nib, forCellReuseIdentifier: model.cellIdentifier)
            cell = dequeueReusableCell(withIdentifier: model.cellIdentifier) as? BaseTableViewCell
        }
        cell!.setup(with: model)
        return cell!
    }

    func heightForHeaderInSection(structure: TableViewStructure, section: Int) -> CGFloat {
        return structure.sections[section].headerModel?.cellHeight ?? 0
    }

    func heightForRow(structure: TableViewStructure, indexPath: IndexPath) -> CGFloat {
        return structure.cellModel(for: indexPath).cellHeight()
    }

    func viewForHeader(structure: TableViewStructure, section: Int) -> UIView? {
        guard section >= 0 && section < structure.sections.count else {
            return nil
        }
        let sectionModel = structure.sections[section]
        guard let model = sectionModel.headerModel else {
            return nil
        }
        var view: TableViewHeaderView? = dequeueReusableHeaderFooterView(withIdentifier: model.reuseIdentifier) as? TableViewHeaderView
        if view == nil {
            let nib = UINib(nibName: model.reuseIdentifier, bundle: .main)
            register(nib, forHeaderFooterViewReuseIdentifier: model.reuseIdentifier)
            view = dequeueReusableHeaderFooterView(withIdentifier: model.reuseIdentifier) as? TableViewHeaderView
        }
        view!.setup(with: model)
        return view
    }
}
