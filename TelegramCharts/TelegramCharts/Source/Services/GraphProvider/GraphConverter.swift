//
//  GraphConverter.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 18/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphConverter {

    static func convert(model: GraphModel, name: String) -> Graph? {
        var dates = [Date]()
        var charts = [Chart]()
        
        for (name, values) in model.columns {
            guard let type = model.types[name] else { continue }
            
            if type == "x" {
                dates = values.map { Date(timeIntervalSince1970: TimeInterval($0 / 1000)) }
            } else {
                guard let title = model.names[name] else { continue }
                guard let colorHex = model.colors[name] else { continue }
                guard let chartType = typeFromString(s: type) else { continue }
                
                let chart = Chart(type: chartType,
                                  name: title,
                                  color: UIColor(hexString: colorHex),
                                  values: values.map { Int($0) })
                charts.append(chart)
            }
        }
        return Graph(name: name, charts: charts, dates: dates, percentage: model.percentage, stacked: model.stacked, yScaled: model.y_scaled)
    }
    
    private static func typeFromString(s: String) -> ChartType? {
        switch s {
        case "line":
            return .line
        case "bar":
            return .bar
        case "area":
            return .area
        default:
            return nil
        }
    }
}
