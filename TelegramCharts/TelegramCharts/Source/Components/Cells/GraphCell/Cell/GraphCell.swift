//
//  GraphCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphCell: BaseCell {
    
    private let textWidth: CGFloat = 44
    private let mainInsets = UIEdgeInsets(top: 32, left: 16, bottom: 24, right: 16)
    
    override class var cellHeight: CGFloat {
        return 320
    }
    
    @IBOutlet weak var delimiterLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var mapContainer: UIView!
    
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
            NSLayoutConstraint(item: mainGraphView, attribute: .top, relatedBy: .equal, toItem: mainContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainGraphView, attribute: .bottom, relatedBy: .equal, toItem: mainContainer, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainGraphView, attribute: .leading, relatedBy: .equal, toItem: mainContainer, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainGraphView, attribute: .trailing, relatedBy: .equal, toItem: mainContainer, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        mapContainer.addConstraints([
            NSLayoutConstraint(item: mapGraphView, attribute: .top, relatedBy: .equal, toItem: mapContainer, attribute: .top, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: mapGraphView, attribute: .bottom, relatedBy: .equal, toItem: mapContainer, attribute: .bottom, multiplier: 1, constant: -1),
            NSLayoutConstraint(item: mapGraphView, attribute: .leading, relatedBy: .equal, toItem: mapContainer, attribute: .leading, multiplier: 1, constant: mainInsets.left),
            NSLayoutConstraint(item: mapGraphView, attribute: .trailing, relatedBy: .equal, toItem: mapContainer, attribute: .trailing, multiplier: 1, constant: -mainInsets.right)
        ])
        mapContainer.addConstraints([
            NSLayoutConstraint(item: rangeSlider, attribute: .top, relatedBy: .equal, toItem: mapContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rangeSlider, attribute: .bottom, relatedBy: .equal, toItem: mapContainer, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rangeSlider, attribute: .leading, relatedBy: .equal, toItem: mapContainer, attribute: .leading, multiplier: 1, constant: mainInsets.left),
            NSLayoutConstraint(item: rangeSlider, attribute: .trailing, relatedBy: .equal, toItem: mapContainer, attribute: .trailing, multiplier: 1, constant: -mainInsets.right)
        ])
    }
    
    override func themeDidUpdate(theme: Theme) {
        startDateLabel.textColor = theme.cellTextColor
        endDateLabel.textColor = theme.cellTextColor
        delimiterLabel.textColor = theme.cellTextColor
        super.themeDidUpdate(theme: theme)
    }
}
