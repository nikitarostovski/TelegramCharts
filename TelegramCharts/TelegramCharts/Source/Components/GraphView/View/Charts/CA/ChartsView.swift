//
//  ChartsView.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartsView: UIView, ChartViewProtocol {
    
    var barWidth: CGFloat {
        get {
            return charts.first?.barWidth ?? 0
        }
    }
    
    private var isMap: Bool
    private var lineWidth: CGFloat
    private var selectionView: UIView
    private var charts: [ChartViewProtocol]
    private weak var dataSource: GraphDataSource?
    
    init(dataSource: GraphDataSource, isMap: Bool, lineWidth: CGFloat) {
        self.dataSource = dataSource
        self.isMap = isMap
        self.lineWidth = lineWidth
        self.charts = [ChartViewProtocol]()
        self.selectionView = UIView()
        self.selectionView.frame.size.width = 1
        super.init(frame: .zero)
        dataSource.chartDataSources.forEach {
            let chartLayer = layerForChart($0)
            addSubview(chartLayer as! UIView)
            charts.append(chartLayer)
        }
        addSubview(selectionView)
        backgroundColor = .clear
        layer.masksToBounds = false
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        charts.forEach { ($0 as! UIView).frame = bounds }
        selectionView.frame.size.height = bounds.height
        update()
    }
    
    func update() {
        guard bounds != .zero else { return }
        charts.forEach { $0.update() }
        if let dataSource = dataSource, let chart = dataSource.chartDataSources.first {
            if let index = chart.selectedIndex, chart.chart.type != .bar {
                let x = (chart.xIndices[index] - chart.viewport.xLo) / chart.viewport.width * bounds.width
                selectionView.center.x = x
                self.selectionView.isHidden = false
                self.selectionView.alpha = 0
                UIView.animate(withDuration: 0.05) {
                    self.selectionView.alpha = 1
                }
            } else {
                self.selectionView.alpha = 1
                UIView.animate(withDuration: 0.05, animations: {
                    self.selectionView.alpha = 0
                }) { (_) in
                    self.selectionView.isHidden = true
                }
            }
        }
    }
    
    private func layerForChart(_ source: ChartDataSource) -> ChartViewProtocol {
        switch source.chart.type {
        case .line:
            return LineChartView(source: source, lineWidth: lineWidth, isMap: isMap)
        case .bar:
            return BarChartView(source: source, lineWidth: lineWidth, isMap: isMap)
        case .area:
            return AreaChartView(source: source, lineWidth: lineWidth, isMap: isMap)
        }
    }
}

extension ChartsView: Stylable {
    func themeDidUpdate(theme: Theme) {
        selectionView.backgroundColor = theme.gridLineColor
    }
}
