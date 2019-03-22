//
//  MainViewController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    var chart: Chart? {
        didSet {
            let queue = DispatchQueue(label: "conversion", qos: .utility, attributes: [], autoreleaseFrequency: .inherit, target: nil)
            queue.async { [weak self] in
                guard let self = self else { return }
                ChartConverter.convert(chart: self.chart) { converted in
                    if let converted = converted {
                        DispatchQueue.main.async {
                            self.chartLines = converted.lines
                            self.chartDates = converted.dates
                            self.createStructure()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    private var chartLines: [ChartLine]?
    private var chartDates: [Date]?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    private var chartCellModel: ChartCellModel {
        let model = ChartCellModel()
        model.chartLines = chartLines
        model.chartDates = chartDates
        model.currentRange = 0.75 ... 1.0
        model.topSeparatorStyle.isHidden = false
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

    private func makeLineCellModel(line: ChartLine, lineIndex: Int) -> CheckCellModel {
        let model = CheckCellModel()
        model.hasCheckmark = true
        model.tagColor = line.color
        model.titleText = line.name
        model.lineIndex = lineIndex
        return model
    }
    
    private func createStructure() {
        structure.clear()

        var lineModels = [CheckCellModel]()
        if let chartLines = chartLines {
            for i in chartLines.indices {
                let model = makeLineCellModel(line: chartLines[i], lineIndex: i)
                if i == chartLines.count - 1 {
                    model.bottomSeparatorStyle.isHidden = false
                    model.bottomSeparatorStyle.clampToEdge = true
                } else {
                    model.bottomSeparatorStyle.isHidden = false
                    model.bottomSeparatorStyle.clampToEdge = false
                }
                model.cellTapAction = { [weak self] (model, cell) in
                    guard let self = self, let model = model as? CheckCellModel else { return }
                    for section in self.structure.sections {
                        for chartModel in section.cellModels {
                            if let chartModel = chartModel as? ChartCellModel {
                                chartModel.linesVisibility![model.lineIndex] = !model.hasCheckmark
                            }
                        }
                    }
                    for cell in self.tableView.visibleCells {
                        guard let cell = cell as? ChartCell else { continue }
                        cell.updateLinesVisibility()
                    }
                }
                lineModels.append(model)
            }
        }

        var chartModels: [BaseCellModel] = [chartCellModel]
        chartModels.append(contentsOf: lineModels)
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
