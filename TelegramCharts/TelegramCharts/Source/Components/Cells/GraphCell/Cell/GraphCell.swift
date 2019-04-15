//
//  GraphCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphCell: BaseCell {
    
    private let textWidth: CGFloat = 48
    private let mainInsets = UIEdgeInsets(top: 32, left: 16, bottom: 24, right: 16)
    
    override class var cellHeight: CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBOutlet weak var delimiterLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var filterContainer: FilterButtonContainer!
    
    var mainGraphView: GraphView!
    var mapGraphView: GraphView!
    var rangeSlider: RangeSlider!

    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? GraphCellModel else { return }
        createViews()

        var insets = mainGraphView.insets
        insets.left /= UIScreen.main.bounds.width
        insets.right /= UIScreen.main.bounds.width
        insets.top = 0
        insets.bottom = 0
        model.dataProvider.setEdgeInsets(insets: insets)
        
        model.dataProvider.redrawHandler = { [weak self] in
            if let first = model.dataProvider.chartDataSources.first {
                let startDate = model.dataProvider.dates[first.lo]
                let endDate = model.dataProvider.dates[first.hi]
                self?.startDateLabel.text = startDate.string(format: .dayMonthYear)
                self?.endDateLabel.text = endDate.string(format: .dayMonthYear)
            } else {
                self?.startDateLabel.text = ""
                self?.endDateLabel.text = ""
            }
            self?.mainGraphView.redraw()
            self?.mapGraphView.redraw()
        }
        model.dataProvider.resetGridValuesHandler = { [weak self] in
            self?.mainGraphView.resetGridValues()
        }
        model.dataProvider.selectionUpdateHandler = { [weak self] in
            self?.mainGraphView.redraw()
        }
        rangeSlider.lowerValue = model.dataProvider.range.lowerBound
        rangeSlider.upperValue = model.dataProvider.range.upperBound
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = model as? GraphCellModel else { return }
        let normTextWidth = textWidth / (bounds.width - mainInsets.left - mainInsets.right)
        model.dataProvider.setNormalizedTextWidth(textWidth: normTextWidth)
        mainGraphView.redraw()
        mapGraphView.redraw()
    }

    private func createViews() {
        guard let model = model as? GraphCellModel else { return }
        if mainGraphView != nil {
            mainGraphView.removeFromSuperview()
        }
        if mapGraphView != nil {
            mapGraphView.removeFromSuperview()
        }
        if rangeSlider != nil {
            rangeSlider.removeFromSuperview()
        }
        mainGraphView = GraphView(dataSource: model.dataProvider, lineWidth: 2.0, insets: mainInsets, isMap: false, textWidth: textWidth)
        mainGraphView.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(mainGraphView)
        
        mapGraphView = GraphView(dataSource: model.dataProvider, lineWidth: 1.0, insets: .zero, isMap: true, textWidth: textWidth)
        mapGraphView.translatesAutoresizingMaskIntoConstraints = false
        mapGraphView.layer.masksToBounds = true
        mapGraphView.layer.cornerRadius = 8
        mapContainer.addSubview(mapGraphView)

        rangeSlider = RangeSlider(frame: .zero, insetX: mainInsets.left)
        rangeSlider.translatesAutoresizingMaskIntoConstraints = false
        rangeSlider.delegate = self.model as? RangeSliderDelegate
        rangeSlider.tintAreaInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        mapContainer.addSubview(rangeSlider)
        
        mainContainer.addConstraints([
            NSLayoutConstraint(item: mainGraphView!, attribute: .top, relatedBy: .equal, toItem: mainContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainGraphView!, attribute: .bottom, relatedBy: .equal, toItem: mainContainer, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainGraphView!, attribute: .leading, relatedBy: .equal, toItem: mainContainer, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainGraphView!, attribute: .trailing, relatedBy: .equal, toItem: mainContainer, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        mapContainer.addConstraints([
            NSLayoutConstraint(item: mapGraphView!, attribute: .top, relatedBy: .equal, toItem: mapContainer, attribute: .top, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: mapGraphView!, attribute: .bottom, relatedBy: .equal, toItem: mapContainer, attribute: .bottom, multiplier: 1, constant: -1),
            NSLayoutConstraint(item: mapGraphView!, attribute: .leading, relatedBy: .equal, toItem: mapContainer, attribute: .leading, multiplier: 1, constant: mainInsets.left),
            NSLayoutConstraint(item: mapGraphView!, attribute: .trailing, relatedBy: .equal, toItem: mapContainer, attribute: .trailing, multiplier: 1, constant: -mainInsets.right)
        ])
        mapContainer.addConstraints([
            NSLayoutConstraint(item: rangeSlider!, attribute: .top, relatedBy: .equal, toItem: mapContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rangeSlider!, attribute: .bottom, relatedBy: .equal, toItem: mapContainer, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rangeSlider!, attribute: .leading, relatedBy: .equal, toItem: mapContainer, attribute: .leading, multiplier: 1, constant: mainInsets.left),
            NSLayoutConstraint(item: rangeSlider!, attribute: .trailing, relatedBy: .equal, toItem: mapContainer, attribute: .trailing, multiplier: 1, constant: -mainInsets.right)
        ])
        
        var buttons = [FilterButton]()
        if model.dataProvider.chartDataSources.count > 1 {
            for i in model.dataProvider.chartDataSources.indices {
                let chartSource = model.dataProvider.chartDataSources[i]
                let b = FilterButton(type: .system)
                b.setTitle(chartSource.chart.name, for: .normal)
                b.color = chartSource.chart.color
                b.isOn = model.dataProvider.chartDataSources[i].visible
                b.onTap = { [weak self] sender in
                    guard let self = self else { return }
                    var canSwitch = true
                    if b.isOn {
                        var isLast = true
                        for f in self.filterContainer.buttons {
                            if f.isOn && f !== b {
                                isLast = false
                                break
                            }
                        }
                        canSwitch = !isLast
                    }
                    if canSwitch {
                        if #available(iOS 10.0, *) {
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                        sender.isOn = !sender.isOn
                        var visibilities: [Bool] = model.dataProvider.chartDataSources.map { $0.visible }
                        visibilities[i] = sender.isOn
                        model.dataProvider.setChartsVisibility(visibilities: visibilities)
                    } else {
                        if #available(iOS 10.0, *) {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                        sender.shake()
                    }
                }
                b.onLongTap = { [weak self] sender in
                    guard let self = self else { return }
                    var visibilities: [Bool] = model.dataProvider.chartDataSources.map { $0.visible }
                    sender.isOn = true
                    for i in self.filterContainer.buttons.indices {
                        let f = self.filterContainer.buttons[i]
                        if f !== b {
                            f.isOn = false
                        }
                        visibilities[i] = f.isOn
                    }
                    model.dataProvider.setChartsVisibility(visibilities: visibilities)
                    if #available(iOS 10.0, *) {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
                buttons.append(b)
            }
        }
        filterContainer.buttons = buttons
        invalidateIntrinsicContentSize()
    }
    
    override func themeDidUpdate(theme: Theme) {
        startDateLabel.textColor = theme.cellTextColor
        endDateLabel.textColor = theme.cellTextColor
        delimiterLabel.textColor = theme.cellTextColor
        super.themeDidUpdate(theme: theme)
    }
}
