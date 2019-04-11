//
//  YAxisDataSource.swift
//  TelegramCharts
//
//  Created by Rost on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum YValueTextMode {
    case value
    case percent
}

struct YAxisViewMode: OptionSet {
    let rawValue: Int
    
    static let left = YAxisViewMode(rawValue: 1)
    static let right = YAxisViewMode(rawValue: 2)
}

class YAxisDataSource {
    
    private var gridPositions: [CGFloat]
    
    private (set) var textMode: YValueTextMode
    private (set) var viewMode: YAxisViewMode
    private (set) var lines: [YValueData]
    
    init(viewMode: YAxisViewMode, textMode: YValueTextMode) {
        self.viewMode = viewMode
        self.textMode = textMode
        self.gridPositions = [0, 0.25, 0.5, 0.75, 1]
        self.lines = []
    }
    
    // TODO: pass Graph (or init)
    func updatePoints(leftSource: [ChartDataSource]?, rightSource: [ChartDataSource]?) {
        lines = []
        for pos in gridPositions {
            var textLeft: String? = nil
            var textRight: String? = nil
            var colorLeft: UIColor? = nil
            var colorRight: UIColor? = nil
            
            if viewMode.contains(.left), let leftSource = leftSource {
                textLeft = getValue(atPos: pos, fromSources: leftSource)
                if let leftSourceFirst = leftSource.first {
                    colorLeft = leftSourceFirst.chart.color
                }
            }
            if viewMode.contains(.right), let rightSource = rightSource {
                textRight = getValue(atPos: pos, fromSources: rightSource)
                if let rightSourceFirst = rightSource.first {
                    colorRight = rightSourceFirst.chart.color
                }
            }
            let line = YValueData(textLeft: textLeft, textRight: textRight, pos: pos)
            if colorLeft != nil, colorRight != nil {
                line.leftColor = colorLeft
                line.rightColor = colorRight
            }
            lines.append(line)
        }
    }
    
    private func getValue(atPos pos: CGFloat, fromSources sources: [ChartDataSource]) -> String {
        var maxVisibleValue: CGFloat = 0
        var minVisibleValue: CGFloat = CGFloat.greatestFiniteMagnitude
        guard textMode != .percent else {
            return String(number: Int(100 * pos))
        }
        for i in sources.indices {
            var sourceMax: CGFloat = 0
            var sourceMin: CGFloat = CGFloat.greatestFiniteMagnitude
            if let sourceA = sources[i] as? LineChartDataSource,
                let aValMax = sourceA.yValues.max(by: { $0.value > $1.value })?.value,
                let aValMin = sourceA.yValues.min(by: { $0.value > $1.value })?.value {
                sourceMax = max(sourceMax, CGFloat(aValMax))
                sourceMin = min(sourceMin, CGFloat(aValMin))
            } else if let sourceA = sources[i] as? BarChartDataSource,
                let aValMax = sourceA.yValues.max(by: { $0.value > $1.value })?.value,
                let aValMin = sourceA.yValues.min(by: { $0.value > $1.value })?.value {
                sourceMax = max(sourceMax, CGFloat(aValMax))
                sourceMin = min(sourceMin, CGFloat(aValMin))
            } else if let sourceA = sources[i] as? AreaChartDataSource,
                let aMax = sourceA.yValues.max(by: {
                    CGFloat($0.value) / CGFloat($0.sumValue) > CGFloat($1.value) / CGFloat($1.sumValue)
                }),
                let aMin = sourceA.yValues.min(by: {
                    CGFloat($0.value) / CGFloat($0.sumValue) > CGFloat($1.value) / CGFloat($1.sumValue)
                }) {
                sourceMax = max(sourceMax, CGFloat(aMax.value) / CGFloat(aMax.sumValue))
                sourceMin = min(sourceMin, CGFloat(aMin.value) / CGFloat(aMin.sumValue))
            }
            maxVisibleValue = max(maxVisibleValue, sourceMax)
            minVisibleValue = min(minVisibleValue, sourceMin)
        }
        return String(number: Int((minVisibleValue + (maxVisibleValue - minVisibleValue)) * pos))
    }
}
