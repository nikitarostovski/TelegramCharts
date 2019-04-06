//
//  MainViewController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    var charts: [Chart]! {
        didSet {
            var lines = [[ChartLine]]()
            var dates = [[Date]]()
            self.charts.forEach { chart in
                ChartConverter.convert(chart: chart) { converted in
                    if let converted = converted {
                        lines.append(converted.lines)
                        dates.append(converted.dates)
                    }
                }
            }
            self.chartLines = lines
            self.chartDates = dates
            self.createStructure()
            self.tableView.reloadData()
        }
    }

    private var chartLines: [[ChartLine]]!
    private var chartDates: [[Date]]!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        charts = ChartProvider.getCharts()
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.canCancelContentTouches = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        startReceivingThemeUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Structure
    
    private var structure = TableViewStructure()
    
    private var followersHeaderModel: TableViewHeaderViewModel {
        let model = TableViewHeaderViewModel()
        model.titleText = "Followers".localized().uppercased()
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

    private func makeChartCellModel(index: Int) -> ChartCellModel {
        let model = ChartCellModel(chartIndex: index, chartLines: chartLines[index], chartDates: chartDates[index], currentRange: 0.75 ... 1.0)
        model.topSeparatorStyle.isHidden = false
        return model
    }

    private func makeLineCellModel(line: ChartLine, lineIndex: Int, chartIndex: Int) -> CheckCellModel {
        let model = CheckCellModel()
        model.hasCheckmark = true
        model.tagColor = line.color
        model.titleText = line.name
        model.chartIndex = chartIndex
        model.lineIndex = lineIndex
        return model
    }
    
    private func createStructure() {
        structure.clear()

        for k in chartLines.indices {
            let lines = chartLines[k]

            var lineModels = [CheckCellModel]()
            for i in lines.indices {
                let model = makeLineCellModel(line: lines[i], lineIndex: i, chartIndex: k)
                if i == lines.count - 1 {
                    model.bottomSeparatorStyle.isHidden = false
                    model.bottomSeparatorStyle.clampToEdge = true
                } else {
                    model.bottomSeparatorStyle.isHidden = false
                    model.bottomSeparatorStyle.clampToEdge = false
                }
                model.cellTapAction = { [weak self] (model, cell) in
                    guard let self = self, let model = model as? CheckCellModel else { return }
                    for section in self.structure.sections {
                        for i in section.cellModels.indices {
                            let chartModel = section.cellModels[i]
                            if let chartModel = chartModel as? ChartCellModel, k == chartModel.chartIndex {
                                chartModel.setLineVisibility(index: model.lineIndex, visible: !model.hasCheckmark)
                            }
                        }
                    }
                }
                lineModels.append(model)
            }

            var chartModels: [BaseCellModel] = [makeChartCellModel(index: k)]
            chartModels.append(contentsOf: lineModels)
            let chartSection = TableViewSection(headerModel: followersHeaderModel, cellModels: chartModels)
            structure.addSection(section: chartSection)

            let settingsModels = [themeCellModel]
            let settingsSection = TableViewSection(headerModel: settingsHeaderModel, cellModels: settingsModels)
            structure.addSection(section: settingsSection)
            structure.addSection(section: TableViewSection(headerModel: settingsHeaderModel, cellModels: []))
        }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Stylable

extension MainViewController: Stylable {

    func themeDidUpdate(theme: Theme) {
        tableView.backgroundColor = theme.viewBackgroundColor
        tableView.separatorColor = theme.tableSeparatorColor
    }
}
