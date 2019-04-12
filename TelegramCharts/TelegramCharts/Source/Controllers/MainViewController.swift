//
//  MainViewController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    @IBOutlet weak var themeBarButton: UIBarButtonItem!
    
    var graphs: [Graph]! {
        didSet {
            self.createStructure()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.graphs = GraphProvider.getGraphs()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 54, right: 0)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 320
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

    private func makeGraphCellModel(index: Int) -> GraphCellModel {
        let model = GraphCellModel(graphIndex: index, graph: graphs[index], currentRange: 0.75 ... 1.0)
        model.topSeparatorStyle.isHidden = false
        return model
    }
    
    private func makeFilterCellModel(index: Int) -> FilterCellModel {
        let model = FilterCellModel(graphIndex: index, graph: graphs[index])
//        let model = GraphCellModel(graphIndex: index, graph: graphs[index], currentRange: 0.75 ... 1.0)
        model.bottomSeparatorStyle.isHidden = false
        return model
    }
    
    private func makeHeaderModel(text: String) -> TableViewHeaderViewModel {
        let model = TableViewHeaderViewModel()
        model.titleText = text
        return model
    }
    
    private func createStructure() {
        structure.clear()
        for i in graphs.indices {
            let header = makeHeaderModel(text: graphs[i].name)
            let graphModel = makeGraphCellModel(index: i)
            let filterModel = makeFilterCellModel(index: i)
            let section = TableViewSection(headerModel: header, cellModels: [graphModel, filterModel])
            structure.addSection(section: section)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func themeTap(_ sender: Any) {
        if ThemeManager.shared.currentTheme == .day {
            setNightTheme()
        } else {
            setDayTheme()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Stylable

extension MainViewController: Stylable {

    func themeDidUpdate(theme: Theme) {
        tableView.backgroundColor = theme.viewBackgroundColor
        tableView.separatorColor = theme.tableSeparatorColor
        
        themeBarButton.tintColor = theme.tintColor
        if theme == .day {
            themeBarButton.title = "Night Mode".localized()
        } else {
            themeBarButton.title = "Day Mode".localized()
        }
    }
}
