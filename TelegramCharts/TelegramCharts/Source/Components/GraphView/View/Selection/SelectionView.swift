//
//  SelectionView.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class SelectionView: UIView {

    var selectionLayer: SelectionLayer
    
    init() {
        selectionLayer = SelectionLayer()
        super.init(frame: .zero)
        layer.addSublayer(selectionLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(index: Int, dataSource: GraphDataSource, animated: Bool = true) {
        let date = dataSource.dates[index]
        let format = DateFormat.weekdayDayMonthYear
        var values = [Int]()
        var colors = [UIColor]()
        var titles = [String]()
        var percents: [String]? = nil
        if dataSource.graph?.percentage == true {
            percents = []
        }
        dataSource.chartDataSources.forEach {
            values.append($0.yValues[index].value)
            colors.append($0.chart.color)
            titles.append($0.chart.name)
            if dataSource.graph?.percentage == true {
                let p = Int(CGFloat($0.yValues[index].value) / CGFloat($0.yValues[index].sumValue) * 100)
                var s = ""
                if p == 0 {
                    s = "<1%"
                } else {
                    s = String(p) + "%"
                }
                percents?.append(s)
            }
        }
        let data = ChartSelectionData(date: date, format: format, values: values, percents: percents, colors: colors, titles: titles)
        selectionLayer.setData(data: data, animated: animated)
        self.frame.size = selectionLayer.plateLayer.frame.size
    }
}
