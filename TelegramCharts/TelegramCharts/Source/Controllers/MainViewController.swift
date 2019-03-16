//
//  MainViewController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    private var chartsData: ChartsData? {

        let dates: [Date] = [1542412800000,
                     1542499200000,
                     1542585600000,
                     1542672000000,
                     1542758400000,
                     1542844800000,
                     1542931200000,
                     1543017600000,
                     1543104000000,
                     1543190400000,
                     1543276800000,
                     1543363200000,
                     1543449600000,
                     1543536000000,
                     1543622400000,
                     1543708800000,
                     1543795200000,
                     1543881600000,
                     1543968000000,
                     1544054400000,
                     1544140800000,
                     1544227200000,
                     1544313600000,
                     1544400000000,
                     1544486400000,
                     1544572800000,
                     1544659200000,
                     1544745600000,
                     1544832000000,
                     1544918400000,
                     1545004800000,
                     1545091200000,
                     1545177600000,
                     1545264000000,
                     1545350400000,
                     1545436800000,
                     1545523200000,
                     1545609600000,
                     1545696000000,
                     1545782400000,
                     1545868800000,
                     1545955200000,
                     1546041600000,
                     1546128000000,
                     1546214400000,
                     1546300800000,
                     1546387200000,
                     1546473600000,
                     1546560000000,
                     1546646400000,
                     1546732800000,
                     1546819200000,
                     1546905600000,
                     1546992000000,
                     1547078400000,
                     1547164800000,
                     1547251200000,
                     1547337600000,
                     1547424000000,
                     1547510400000,
                     1547596800000,
                     1547683200000,
                     1547769600000,
                     1547856000000,
                     1547942400000,
                     1548028800000,
                     1548115200000,
                     1548201600000,
                     1548288000000,
                     1548374400000,
                     1548460800000,
                     1548547200000,
                     1548633600000,
                     1548720000000,
                     1548806400000,
                     1548892800000,
                     1548979200000,
                     1549065600000,
                     1549152000000,
                     1549238400000,
                     1549324800000,
                     1549411200000,
                     1549497600000,
                     1549584000000,
                     1549670400000,
                     1549756800000,
                     1549843200000,
                     1549929600000,
                     1550016000000,
                     1550102400000,
                     1550188800000,
                     1550275200000,
                     1550361600000,
                     1550448000000,
                     1550534400000,
                     1550620800000,
                     1550707200000,
                     1550793600000,
                     1550880000000,
                     1550966400000,
                     1551052800000,
                     1551139200000,
                     1551225600000,
                     1551312000000,
                     1551398400000,
                     1551484800000,
                     1551571200000,
                     1551657600000,
                     1551744000000,
                     1551830400000,
                     1551916800000,
                     1552003200000].map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let testDataA: [Int64] = [37,
                                          20,
                                          32,
                                          39,
                                          32,
                                          35,
                                          19,
                                          65,
                                          36,
                                          62,
                                          113,
                                          69,
                                          120,
                                          60,
                                          51,
                                          49,
                                          71,
                                          122,
                                          149,
                                          69,
                                          57,
                                          21,
                                          33,
                                          55,
                                          92,
                                          62,
                                          47,
                                          50,
                                          56,
                                          116,
                                          63,
                                          60,
                                          55,
                                          65,
                                          76,
                                          33,
                                          45,
                                          64,
                                          54,
                                          81,
                                          180,
                                          123,
                                          106,
                                          37,
                                          60,
                                          70,
                                          46,
                                          68,
                                          46,
                                          51,
                                          33,
                                          57,
                                          75,
                                          70,
                                          95,
                                          70,
                                          50,
                                          68,
                                          63,
                                          66,
                                          53,
                                          38,
                                          52,
                                          109,
                                          121,
                                          53,
                                          36,
                                          71,
                                          96,
                                          55,
                                          58,
                                          29,
                                          31,
                                          55,
                                          52,
                                          44,
                                          126,
                                          191,
                                          73,
                                          87,
                                          255,
                                          278,
                                          219,
                                          170,
                                          129,
                                          125,
                                          126,
                                          84,
                                          65,
                                          53,
                                          154,
                                          57,
                                          71,
                                          64,
                                          75,
                                          72,
                                          39,
                                          47,
                                          52,
                                          73,
                                          89,
                                          156,
                                          86,
                                          105,
                                          88,
                                          45,
                                          33,
                                          56,
                                          142,
                                          124,
                                          114,
                                          64]
        let testDataB: [Int64] = [22,
                                          12,
                                          30,
                                          40,
                                          33,
                                          23,
                                          18,
                                          41,
                                          45,
                                          69,
                                          57,
                                          61,
                                          70,
                                          47,
                                          31,
                                          34,
                                          40,
                                          55,
                                          27,
                                          57,
                                          48,
                                          32,
                                          40,
                                          49,
                                          54,
                                          49,
                                          34,
                                          51,
                                          51,
                                          51,
                                          66,
                                          51,
                                          94,
                                          60,
                                          64,
                                          28,
                                          44,
                                          96,
                                          49,
                                          73,
                                          30,
                                          88,
                                          63,
                                          42,
                                          56,
                                          67,
                                          52,
                                          67,
                                          35,
                                          61,
                                          40,
                                          55,
                                          63,
                                          61,
                                          105,
                                          59,
                                          51,
                                          76,
                                          63,
                                          57,
                                          47,
                                          56,
                                          51,
                                          98,
                                          103,
                                          62,
                                          54,
                                          104,
                                          48,
                                          41,
                                          41,
                                          37,
                                          30,
                                          28,
                                          26,
                                          37,
                                          65,
                                          86,
                                          70,
                                          81,
                                          54,
                                          74,
                                          70,
                                          50,
                                          74,
                                          79,
                                          85,
                                          62,
                                          36,
                                          46,
                                          68,
                                          43,
                                          66,
                                          50,
                                          28,
                                          66,
                                          39,
                                          23,
                                          63,
                                          74,
                                          83,
                                          66,
                                          40,
                                          60,
                                          29,
                                          36,
                                          27,
                                          54,
                                          89,
                                          50,
                                          73,
                                          52]
        let lineA = (testDataA, UIColor(hexString: "4bd964"))
        let lineB = (testDataB, UIColor(hexString: "fe3c30"))
        
        return ChartsData(xTitles: dates.map { PrintableDate(date: $0) }, lines: [lineA, lineB])
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
        model.chartsData = chartsData
        model.topSeparatorStyle.isHidden = false
        return model
    }
    private var chartRangeCellModel: ChartRangeTableViewCellModel {
        let model = ChartRangeTableViewCellModel()
        model.chartsData = chartsData
        model.initialRange = 0.75 ... 1.0
        model.rangeChangeAction = { [weak self] range in
            self?.chartRangeChange(range: range)
        }
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

    private func chartRangeChange(range: ClosedRange<CGFloat>) {
        var chartCellModels = [ChartTableViewCellModel]()
        structure.sections.forEach { section in
            section.cellModels.forEach { model in
                if model is ChartTableViewCellModel {
                    chartCellModels.append(model as! ChartTableViewCellModel)
                }
            }
        }
        chartCellModels.forEach {
            $0.visibleRange = range
        }
        tableView.visibleCells.forEach {
            guard let chartCell = $0 as? ChartTableViewCell else { return }
            chartCell.updateAppearance()
        }
    }
    
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
