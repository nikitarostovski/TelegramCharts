//
//  MetalLineDataProvider.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MetalLineDataProvider: MetalDataProvider {
    
    private weak var dataSource: LineChartDataSource?
    private var isMap: Bool
    var lineWidth: CGFloat
    var renderData: [RenderVertex]
    
    init(source: ChartDataSource, lineWidth: CGFloat, isMap: Bool) {
        guard let source = source as? LineChartDataSource else { fatalError() }
        self.lineWidth = lineWidth
        self.renderData = []
        self.isMap = isMap
        self.dataSource = source
    }
    
    func update() {
        guard let dataSource = dataSource else { return }
        let startIndex: Int
        let finishIndex: Int
        let viewport: Viewport
        if isMap {
            viewport = dataSource.mapViewport
            startIndex = 0
            finishIndex = dataSource.yValues.count - 1
        } else {
            viewport = dataSource.viewport
            startIndex = dataSource.loVis
            finishIndex = dataSource.hiVis
        }
        guard viewport.width > 0,
            viewport.height > 0
            else {
                return
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        dataSource.chart.color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var newRenderData = [RenderVertex]()
        var lastX: CGFloat? = nil
        var lastY: CGFloat? = nil
        for i in startIndex ... finishIndex {
            let x = CGFloat(2) * (dataSource.xIndices[i] - viewport.xLo) / viewport.width - CGFloat(1)
            let y = ((CGFloat(dataSource.yValues[i].value) - viewport.yLo) / viewport.height) * CGFloat(2) - CGFloat(1)
            
            if let lastX = lastX, let lastY = lastY {
                
                let angle = atan2(y - lastY, x - lastX)
                let dc = 3 * lineWidth * cos(angle + .pi / 2)
                let ds = 3 * lineWidth * sin(angle + .pi / 2)
                
                let x1 = lastX + dc
                let y1 = lastY + ds
                let x2 = lastX - dc
                let y2 = lastY - ds
                
                let x3 = x + dc
                let y3 = y + ds
                let x4 = x - dc
                let y4 = y - ds
                
                newRenderData.append(RenderVertex(x: x1, y: y1, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: x2, y: y2, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: x4, y: y4, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: x4, y: y4, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: x3, y: y3, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: x1, y: y1, r: r, g: g, b: b, a: a))
            }
            lastX = x
            lastY = y
        }
        self.renderData = newRenderData
    }
}
