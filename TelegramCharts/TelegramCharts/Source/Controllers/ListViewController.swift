//
//  ListViewController.swift
//  TelegramCharts
//
//  Created by Rost on 17/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    private var charts: [Chart]?
    private var selectedIndex: Int?
    
    private var structure = TableViewStructure()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        charts = ChartProvider.getCharts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startReceivingThemeUpdates()
        createStructure()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Actions
    
    private func setDayTheme() {
        ThemeManager.shared.currentTheme = .day
    }
    
    private func setNightTheme() {
        ThemeManager.shared.currentTheme = .night
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MainViewController {
            guard let selectedIndex = selectedIndex,
                let charts = charts
            else {
                return
            }
            if selectedIndex > 0 && selectedIndex < charts.count {
                (segue.destination as! MainViewController).chart = charts[selectedIndex]
            }
        }
    }
}

// MARK: - Structure

extension ListViewController {
    
    private var headerModel: TableViewHeaderViewModel {
        let model = TableViewHeaderViewModel()
        model.titleText = "Statistics available".localized().uppercased()
        return model
    }
    private var settingsHeaderModel: TableViewHeaderViewModel {
        let model = TableViewHeaderViewModel()
        return model
    }
    private var themeCellModel: ButtonCellModel {
        let model = ButtonCellModel()
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
    
    private func makeChartCellModel(chart: Chart, index: Int) -> ItemCellModel {
        let model = ItemCellModel()
        if index == 0 {
            model.topSeparatorStyle.isHidden = false
        }
        model.bottomSeparatorStyle.isHidden = false
        if index != charts!.count - 1 {
            model.bottomSeparatorStyle.clampToEdge = false
        }
        model.titleText = "Statistics " + String(index)
        model.cellTapAction = { [weak self] in
            self?.selectedIndex = index
            self?.performSegue(withIdentifier: "showChart", sender: nil)
        }
        return model
    }
    
    private func createStructure() {
        structure.clear()
        guard let charts = charts else { return }
        
        var chartModels = [ItemCellModel]()
        for i in charts.indices {
            let chart = charts[i]
            chartModels.append(makeChartCellModel(chart: chart, index: i))
        }
        let chartSection = TableViewSection(headerModel: headerModel, cellModels: chartModels)
        structure.addSection(section: chartSection)
        
        let settingsModels = [themeCellModel]
        let settingsSection = TableViewSection(headerModel: settingsHeaderModel, cellModels: settingsModels)
        structure.addSection(section: settingsSection)
    }
}

// MARK: - UITableView DataSource

extension ListViewController {
    
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

extension ListViewController {
    
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

extension ListViewController: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        tableView.backgroundColor = theme.viewBackgroundColor
        tableView.separatorColor = theme.tableSeparatorColor
    }
}
