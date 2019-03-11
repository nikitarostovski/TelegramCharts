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

        let testDataA = ChartData(values: [6706, 7579, 7798, 8307, 7866, 7736, 7816, 7630, 7536, 7105, 7178, 7619, 7917, 7483, 5772, 5700, 5435, 4837, 4716, 4890, 4753, 4820, 4538, 12162, 39444, 25765, 18012, 14421, 13249, 11310, 10377, 9399, 8917, 8259, 7902, 9442, 47596, 36160, 23866, 18500, 15488, 13722, 12270, 13413, 10574, 7092, 7159, 7880, 8821, 8306, 7780, 7963, 7837, 7611, 7334, 7413, 7015, 6742, 6557, 6593, 6680, 6725, 6345, 5988, 6365, 9911, 28833, 19694, 14873, 11911, 10498, 9708, 8893, 8365, 7960, 7694, 45529, 42858, 31508, 23289, 19147, 15874, 14551, 13124, 11778, 10809, 10522, 9918, 9436, 8617, 8765, 8194, 8035, 7865, 7573, 7422, 7047, 7147, 6861, 6669, 6363, 12073, 32381, 21390, 15311, 12819, 11655, 10696, 9678, 9143, 8296, 7852], color: UIColor(hexString: "fe3c30"))
        let testDataB = ChartData(values: [3522, 4088, 4146, 4477, 4202, 4157, 4177, 4203, 4223, 3948, 3946, 3898, 3979, 4052, 3279, 3229, 3302, 3040, 3054, 2982, 3077, 2965, 2973, 5148, 22485, 13077, 9055, 7446, 6824, 5995, 5787, 5367, 4997, 4689, 4630, 4785, 22365, 15244, 10626, 8666, 7681, 6929, 6219, 6367, 5402, 4932, 4844, 5146, 5265, 4887, 4714, 4722, 4718, 4693, 4746, 4819, 4455, 4419, 4323, 4407, 4277, 11589, 6100, 5076, 4769, 8929, 14002, 9756, 7520, 6343, 5633, 5415, 5052, 4850, 4624, 4480, 14102, 24005, 14263, 10845, 9028, 7755, 7197, 7001, 6737, 6254, 6150, 5922, 5603, 5048, 5423, 5003, 5035, 4747, 4814, 4661, 4462, 4516, 4221, 4111, 4053, 12515, 15781, 10499, 8175, 6831, 6287, 5990, 5590, 5148, 4760, 4809], color: UIColor(hexString: "4bd964"))
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
    private var chartRangeCellModel: ChartRangeTableViewCellModel {
        let model = ChartRangeTableViewCellModel()
        model.chartData = chartData
        return model
    }
    private var joinedCellModel: CheckTableViewCellModel {
        let model = CheckTableViewCellModel()
        model.hasCheckmark = true
        model.tagColor = UIColor(hexString: "4bd964")
        model.titleText = "Joined Channel"
        model.bottomSeparatorStyle.isHidden = false
        model.bottomSeparatorStyle.clampToEdge = false
        return model
    }
    private var leftCellModel: CheckTableViewCellModel {
        let model = CheckTableViewCellModel()
        model.hasCheckmark = false
        model.tagColor = UIColor(hexString: "fe3c30")
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
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
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
