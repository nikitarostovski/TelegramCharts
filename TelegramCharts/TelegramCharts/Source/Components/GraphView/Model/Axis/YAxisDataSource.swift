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

typealias YAxisResetHandler = () -> Void

class YAxisDataSource {
    
    private (set) weak var graph: Graph?
    private (set) var sources: [ChartDataSource]
    private (set) var gridPositions: [CGFloat]
    
    private (set) var textMode: YValueTextMode
    private (set) var lastValues: [YValueData]
    private (set) var values: [YValueData]
    
    var color: UIColor? = nil
    var alignment: Alignment = .fill
    var resetHandler: YAxisResetHandler?
    var resetNeeded = false
    
    var lastViewport: Viewport
    var viewport: Viewport
    var targetViewport: Viewport
    
    var needReset: Bool {
        return (values.count == 0) || (targetViewport.yHi != viewport.yHi) || (targetViewport.yLo != viewport.yLo)
    }
    
    init(graph: Graph, sources: [ChartDataSource]) {
        self.sources = sources
        self.graph = graph
        self.viewport = Viewport()
        self.lastViewport = Viewport()
        self.targetViewport = Viewport()
        self.textMode = graph.percentage ? .percent : .value
        self.gridPositions = [0, 0.2, 0.4, 0.6, 0.8, 1]
        self.lastValues = []
        self.values = []
    }
    
    func resetValues() {
        guard sources.count > 0, let graph = graph else { return }
        lastValues = values
        lastValues.forEach {
            $0.lastOpacity = $0.opacity
            $0.targetOpacity = 0
        }
        values = []
        if graph.yScaled {
            color = sources.first!.chart.color
        }
        for pos in gridPositions {
            let val = targetViewport.yLo + targetViewport.height * pos
            let line = YValueData(value: val)
            values.append(line)
        }
        return
    }
    
    func updateViewport() {
        if textMode == .percent {
            targetViewport.yLo = 0
            targetViewport.yHi = 100
        } else {
            calculateViewport(target: &targetViewport)
        }
    }
    
    private func calculateViewport(target: inout Viewport) {
        guard sources.count > 0 else { return }
        var newViewport: Viewport? = nil
        sources.forEach { source in
            guard newViewport != nil else {
                newViewport = source.targetViewport
                return
            }
            newViewport!.yLo = min(newViewport!.yLo, source.targetViewport.yLo)
            newViewport!.yHi = max(newViewport!.yHi, source.targetViewport.yHi)
        }
        target.yLo = newViewport!.yLo
        target.yHi = newViewport!.yHi
    }
}
