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
        return 340
    }

    var mainGraphView: GraphView!
    var mapGraphView: GraphView!
    
    var rangeSlider: RangeSlider!

    override func updateAppearance() {
        super.updateAppearance()
        guard let model = model as? GraphCellModel else { return }
        createViews()

        model.dataProvider.redrawHandler = {  [weak self] in
            self?.mainGraphView.redraw()
            self?.mapGraphView.redraw()
        }
        /*
        model.dataProvider.mapRedrawHandler = { [weak self] in
            self?.mapChartView.updateChartPositions()
        }
        model.dataProvider.updateAlphaHandler = { [weak self] in
            self?.mainChartView.updateChartAlpha()
            self?.mapChartView.updateChartAlpha()
        }*/
        
//        model.dataProvider.hideSelectionHandler = { [weak self] in
//            self?.mainChartView.hideSelection()
//        }
//        model.dataProvider.updateSelectionHandler = { [weak self] in
//            self?.mainChartView.moveSelection(animated: true)
//        }
        
        rangeSlider.lowerValue = model.dataProvider.range.lowerBound
        rangeSlider.upperValue = model.dataProvider.range.upperBound
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()

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
        mapGraphView = GraphView(dataSource: model.dataProvider, lineWidth: 1.0, isMap: true)
        addSubview(mapGraphView)
        addSubview(mainGraphView)

        rangeSlider = RangeSlider(frame: .zero, insetX: 16)
        rangeSlider.delegate = self.model as? RangeSliderDelegate
        addSubview(rangeSlider)
    }

    private func updateFrames() {
        let mapHeight: CGFloat = 40
        let mapFrame = CGRect(x: 16, y: bounds.height - mapHeight - 16, width: bounds.width - 32, height: mapHeight)
        let mainFrame = CGRect(x: 16, y: 0, width: bounds.width - 32, height: mapFrame.minY - 16)
        let sliderFrame = CGRect(x: 0, y: mapFrame.origin.y - 1, width: bounds.width, height: mapFrame.size.height + 2)

        mainGraphView.frame = mainFrame
        mapGraphView.frame = mapFrame
        rangeSlider.frame = sliderFrame
        
        mapGraphView.layer.cornerRadius = 8
        mapGraphView.layer.masksToBounds = true

        let insetTop = mapGraphView.frame.minY - rangeSlider.frame.minY
        let insetBottom = rangeSlider.frame.maxY - mapGraphView.frame.maxY
        rangeSlider.tintAreaInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: insetBottom, right: 0)
    }
}
