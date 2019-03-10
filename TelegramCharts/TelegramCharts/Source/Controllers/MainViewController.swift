//
//  MainViewController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        ChartTableViewCellModel.registerNib(for: tableView)
        ColorTagTableViewCellModel.registerNib(for: tableView)
        ButtonTableViewCellModel.registerNib(for: tableView)
        TableViewHeaderViewModel.registerNib(for: tableView)
        createStructure()
    }
    
    // MARK: - Structure
    
    private var structure = TableViewStructure()
    
    
    private var followersHeaderModel: TableViewHeaderViewModel {
        let model = TableViewHeaderViewModel()
        model.titleText = "Followers".localizedUppercase
        return model
    }
    private var chartCellModel: ChartTableViewCellModel {
        let model = ChartTableViewCellModel()
        return model
    }
    private var joinedCellModel: ColorTagTableViewCellModel {
        let model = ColorTagTableViewCellModel()
        return model
    }
    private var leftCellModel: ColorTagTableViewCellModel {
        let model = ColorTagTableViewCellModel()
        return model
    }
    private var themeCellModel: ButtonTableViewCellModel {
        let model = ButtonTableViewCellModel()
        return model
    }
    
    private func createStructure() {
        structure.clear()
        
        let chartModels = [chartCellModel, joinedCellModel, leftCellModel]
        let chartSection = TableViewSection(headerModel: followersHeaderModel, cellModels: chartModels)
        structure.addSection(section: chartSection)
        
        let settingsModels = [themeCellModel]
        let settingsSection = TableViewSection(headerModel: nil, cellModels: settingsModels)
        structure.addSection(section: settingsSection)
    }
    
}

// MARK: - UITableView DataSource

extension MainViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return structure.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure.sections[section].cellModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = structure.cellModel(for: indexPath)
        let identifier = type(of: cellModel).cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let baseCell = cell as? BaseTableViewCell {
            baseCell.setup(with: cellModel)
        }
        return cell
    }
}

// MARK: - UITableView Delegate

extension MainViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderViewModel.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return structure.cellModel(for: indexPath).cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section >= 0 && section < structure.sections.count else {
            return nil
        }
        let sectionModel = structure.sections[section]
        guard let headerModel = sectionModel.headerModel else {
            return nil
        }
        let identifier = type(of: headerModel).reuseIdentifier
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if let headerView = view as? TableViewHeaderView {
            headerView.setup(with: headerModel)
        }
        return view
    }
}
