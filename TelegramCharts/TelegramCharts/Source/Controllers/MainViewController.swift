//
//  MainViewController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    private var chartData: [ChartData] {
        let testDataA = ChartData(values: [3,7,3,9,2,1,6], color: .red)
        let testDataB = ChartData(values: [9,6,7,0,5,4,4], color: .green)
        return [testDataA, testDataB]
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        createStructure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startReceivingThemeUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopReceivingThemeUpdates()
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
        model.chartData = chartData
        model.topSeparatorStyle.isHidden = false
        return model
    }
    private var chartRangeCellModel: RangeTableViewCellModel {
        let model = RangeTableViewCellModel()
        return model
    }
    private var joinedCellModel: CheckTableViewCellModel {
        let model = CheckTableViewCellModel()
        model.hasCheckmark = true
        model.tagColor = UIColor.green
        model.titleText = "Joined Channel"
        model.bottomSeparatorStyle.isHidden = false
        model.bottomSeparatorStyle.clampToEdge = false
        return model
    }
    private var leftCellModel: CheckTableViewCellModel {
        let model = CheckTableViewCellModel()
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
        if ThemeManager.shared.currentTheme == .day {
            model.buttonTitle = dayModeTitle
        } else {
            model.buttonTitle = nightModeTitle
        }
        
        model.buttonTouchUpInsideAction = { [weak self] in
            guard let self = self else { return }
            if ThemeManager.shared.currentTheme == .day {
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
        
        let chartModels = [chartCellModel, chartRangeCellModel, joinedCellModel, leftCellModel]
        let chartSection = TableViewSection(headerModel: followersHeaderModel, cellModels: chartModels)
        structure.addSection(section: chartSection)
        
        let settingsModels = [themeCellModel]
        let settingsSection = TableViewSection(headerModel: settingsHeaderModel, cellModels: settingsModels)
        structure.addSection(section: settingsSection)
    }
    
    // MARK: - Actions
    
    private func setDayTheme() {
        ThemeManager.shared.currentTheme = .day
    }
    
    private func setNightTheme() {
        ThemeManager.shared.currentTheme = .night
    }
}

// MARK: - UITableView DataSource

extension MainViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.numberOfSections(in: structure)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRows(in: structure, section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(with: structure, indexPath: indexPath)
    }
}

// MARK: - UITableView Delegate

extension MainViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.heightForHeaderInSection(structure: structure, section: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.heightForRow(structure: structure, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.viewForHeader(structure: structure, section: section)
    }
}

// MARK: - Stylable

extension MainViewController: Stylable {

    func themeDidUpdate(theme: Theme) {
        tableView.backgroundColor = theme.viewBackgroundColor
        tableView.separatorColor = theme.tableSeparatorColor
    }
}
