//
//  GraphCell.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphCell: BaseCell {
    
    override class var cellHeight: CGFloat {
        return 320
    }
    
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var mapContainer: UIView!
    
    var mainGraphView: GraphView!
    var mapGraphView: GraphView!
    var rangeSlider: RangeSlider!

    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? GraphCellModel else { return }
        createViews()

        model.dataProvider.redrawHandler = { [weak self] in
            self?.mainGraphView.redraw()
            self?.mapGraphView.redraw()
        }
        model.dataProvider.resetGridValuesHandler = { [weak self] in
            self?.mainGraphView.resetGridValues()
        }
        
        rangeSlider.lowerValue = model.dataProvider.range.lowerBound
        rangeSlider.upperValue = model.dataProvider.range.upperBound
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = model as? GraphCellModel else { return }
        let normTextWidth = CGFloat(60) / bounds.width
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
        mainGraphView = GraphView(dataSource: model.dataProvider, lineWidth: 2.0, isMap: false)
        mainGraphView.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(mainGraphView)
        
        mapGraphView = GraphView(dataSource: model.dataProvider, lineWidth: 1.0, isMap: true)
        mapGraphView.translatesAutoresizingMaskIntoConstraints = false
        mapGraphView.layer.masksToBounds = true
        mapGraphView.layer.cornerRadius = 8
        mapContainer.addSubview(mapGraphView)

        rangeSlider = RangeSlider(frame: .zero, insetX: 16)
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
            NSLayoutConstraint(item: mapGraphView, attribute: .leading, relatedBy: .equal, toItem: mapContainer, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mapGraphView, attribute: .trailing, relatedBy: .equal, toItem: mapContainer, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        mapContainer.addConstraints([
            NSLayoutConstraint(item: rangeSlider, attribute: .top, relatedBy: .equal, toItem: mapContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rangeSlider, attribute: .bottom, relatedBy: .equal, toItem: mapContainer, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rangeSlider, attribute: .leading, relatedBy: .equal, toItem: mapContainer, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rangeSlider, attribute: .trailing, relatedBy: .equal, toItem: mapContainer, attribute: .trailing, multiplier: 1, constant: 0)
        ])
    }
}
