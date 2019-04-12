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

enum Alignment {
    case left
    case right
    case fill
}

class YAxisDataSource {
    
    private weak var graph: Graph?
    private var gridPositions: [CGFloat]
    private var viewport: Viewport
    
    private (set) var textMode: YValueTextMode
    private (set) var lines: [YValueData]
    
    var color: UIColor? = nil
    var alignment: Alignment = .fill
    
    init(graph: Graph) {
        self.graph = graph
        self.viewport = Viewport()
        self.textMode = graph.percentage ? .percent : .value
        self.gridPositions = [0, 0.25, 0.5, 0.75, 1]
        self.lines = []
    }
    
    func updatePoints(chartSources: [ChartDataSource]) {
        guard chartSources.count > 0, let graph = graph else { return }
        lines = []
        if textMode == .percent {
            self.viewport.yLo = 0
            self.viewport.yHi = 100
        } else {
            if graph.yScaled {
                color = chartSources.first!.chart.color
            }
            calculateViewport(viewport: &viewport, sources: chartSources)
        }
        for pos in gridPositions {
            var text: String? = nil
            let val = viewport.yLo + viewport.height * pos
            if !val.isNaN, !val.isInfinite {
                text = String(number: Int(val))
            }
            guard text != nil else { continue }
            let line = YValueData(text: text!, pos: pos)
            lines.append(line)
        }
    }
    
    private func calculateViewport(viewport: inout Viewport, sources: [ChartDataSource]) {
        var newViewport: Viewport? = nil
        sources.forEach { source in
            guard newViewport != nil else {
                newViewport = source.viewport
                return
            }
            newViewport!.yLo = min(newViewport!.yLo, source.viewport.yLo)
            newViewport!.yHi = max(newViewport!.yHi, source.viewport.yHi)
        }
        var valueMin: CGFloat? = nil
        var valueMax: CGFloat? = nil
        sources.forEach { source in
            if let sourceMax = source.yValues.max(by: { $0.value > $1.value }) {
                if valueMax == nil {
                    valueMax = CGFloat(sourceMax.value)
                    return
                }
                valueMax! = max(valueMax!, CGFloat(sourceMax.value))
            }
            if let sourceMin = source.yValues.min(by: { $0.value > $1.value }) {
                if valueMin == nil {
                    valueMin = CGFloat(sourceMin.value)
                    return
                }
                valueMin! = min(valueMin!, CGFloat(sourceMin.value))
            }
        }
        if valueMin != nil {
            viewport.yLo = valueMin!
        }
        if valueMax != nil {
            viewport.yHi = valueMax!
        }
    }
}
