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
        
        createStructure()
    }
    
    // MARK: - Structure
    
    private var structure = TableViewStructure()
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
        
        let chartSectionTitle = "Followers".localizedUppercase
        let chartSectionModels = [chartCellModel, joinedCellModel, leftCellModel]
        let chartSection = TableViewSection(title: chartSectionTitle, cellsModels: chartSectionModels)
        structure.addSection(section: chartSection)
        
        let settingsSectionTitle = ""
        let settingsSectionModels = [themeCellModel]
        let settingsSection = TableViewSection(title: settingsSectionTitle, cellsModels: settingsSectionModels)
        structure.addSection(section: settingsSection)
    }
    
}

// MARK: - UITableView DataSource

extension MainViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return structure.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure.sections[section].cellsModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = structure.cellModel(for: indexPath)
        let identifier = type(of: cellModel).cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }
}

// MARK: - UITableView Delegate

extension MainViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return structure.cellModel(for: indexPath).cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section >= 0 && section < structure.sections.count else {
            return nil
        }
        let sectionModel = structure.sections[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        let label = UILabel(frame: view.bounds)
        label.text = sectionModel.title
        
        return view
    }
}
