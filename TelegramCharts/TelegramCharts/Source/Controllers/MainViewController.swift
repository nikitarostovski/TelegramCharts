//
//  MainViewController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    private var theme = Theme(style: .day)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        ChartTableViewCellModel.registerNib(for: tableView)
        ColorTagTableViewCellModel.registerNib(for: tableView)
        ButtonTableViewCellModel.registerNib(for: tableView)
        TableViewHeaderViewModel.registerNib(for: tableView)
        createStructure()
    }
    
    private func updateAppearance() {
        UIView.animate(withDuration: 0.15) {
            if let navController = self.navigationController as? RootNavigationController {
                navController.theme = self.theme
            }
            self.tableView.backgroundColor = self.theme.viewBackgroundColor
            self.tableView.separatorColor = self.theme.tableSeparatorColor
            
            self.tableView.visibleCells.forEach { [weak self] in
                guard let cell = $0 as? BaseTableViewCell else {
                    return
                }
                cell.theme = self?.theme
            }
            self.tableView.visibleSectionHeaders.forEach { [weak self] in
                guard let header = $0 as? TableViewHeaderView else {
                    return
                }
                header.theme = self?.theme
            }
        }
    }
    
    // MARK: - Structure
    
    private var structure = TableViewStructure()
    
    
    private var followersHeaderModel: TableViewHeaderViewModel {
        let model = TableViewHeaderViewModel()
        model.titleText = "Followers".localized().uppercased()
        return model
    }
    private var chartCellModel: ChartTableViewCellModel {
        let model = ChartTableViewCellModel()
        model.topSeparatorStyle.isHidden = false
        return model
    }
    private var joinedCellModel: ColorTagTableViewCellModel {
        let model = ColorTagTableViewCellModel()
        model.hasCheckmark = true
        model.tagColor = UIColor.green
        model.titleText = "Joined Channel"
        model.topSeparatorStyle.isHidden = false
        model.bottomSeparatorStyle.isHidden = false
        model.bottomSeparatorStyle.clampToEdge = false
        return model
    }
    private var leftCellModel: ColorTagTableViewCellModel {
        let model = ColorTagTableViewCellModel()
        model.hasCheckmark = false
        model.tagColor = UIColor.red
        model.titleText = "Left Channel"
        model.bottomSeparatorStyle.isHidden = false
        return model
    }
    private var settingsHeaderModel: TableViewHeaderViewModel {
        let model = TableViewHeaderViewModel()
        return model
    }
    private var themeCellModel: ButtonTableViewCellModel {
        let model = ButtonTableViewCellModel()
        model.topSeparatorStyle.isHidden = false
        model.bottomSeparatorStyle.isHidden = false
        let dayModeTitle = "Switch to Night Mode".localized()
        let nightModeTitle = "Switch to Day Mode".localized()
        if self.theme.style == .day {
            model.buttonTitle = dayModeTitle
        } else {
            model.buttonTitle = nightModeTitle
        }
        
        model.buttonTouchUpInsideAction = { [weak self] in
            guard let self = self else { return }
            if self.theme.style == .day {
                self.setNightTheme()
                model.buttonTitle = nightModeTitle
            } else {
                self.setDayTheme()
                model.buttonTitle = dayModeTitle
            }
        }
        return model
    }
    
    private func createStructure() {
        structure.clear()
        
        let chartModels = [chartCellModel, joinedCellModel, leftCellModel]
        let chartSection = TableViewSection(headerModel: followersHeaderModel, cellModels: chartModels)
        structure.addSection(section: chartSection)
        
        let settingsModels = [themeCellModel]
        let settingsSection = TableViewSection(headerModel: settingsHeaderModel, cellModels: settingsModels)
        structure.addSection(section: settingsSection)
    }
    
    // MARK: - Actions
    
    private func setDayTheme() {
        theme.style = .day
        updateAppearance()
    }
    
    private func setNightTheme() {
        theme.style = .night
        updateAppearance()
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
            baseCell.theme = theme
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
            headerView.theme = theme
        }
        return view
    }
}
