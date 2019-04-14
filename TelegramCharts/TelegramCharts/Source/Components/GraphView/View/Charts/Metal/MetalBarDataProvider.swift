//
//  MetalBarDataProvider.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MetalBarDataProvider: MetalDataProvider {
    
    private weak var dataSource: BarChartDataSource?
    private var isMap: Bool
    var lineWidth: CGFloat = 0
    var renderData: [RenderVertex]
    
    init(source: ChartDataSource, lineWidth: CGFloat, isMap: Bool) {
        guard let source = source as? BarChartDataSource else { fatalError() }
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
        let distance = dataSource.xIndices[1] - dataSource.xIndices[0]
        let columnWidth = CGFloat(2) * distance
        var lastXRight: CGFloat? = nil
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        let tintAlpha: CGFloat = 0.25
        
        dataSource.chart.color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var newRenderData = [RenderVertex]()
        for i in startIndex ... finishIndex {
            let x = CGFloat(2) * (dataSource.xIndices[i] - viewport.xLo) / viewport.width - CGFloat(1)
            let yLo = ((CGFloat(dataSource.yValues[i].offset) - viewport.yLo) / viewport.height) * CGFloat(2) - CGFloat(1)
            let yHi = ((CGFloat(dataSource.yValues[i].offset + dataSource.yValues[i].value) - viewport.yLo) / viewport.height) * CGFloat(2) - CGFloat(1)
            
            var xLeft: CGFloat
            if let lastXRight = lastXRight {
                xLeft = lastXRight
            } else {
                xLeft = x - columnWidth / 2
            }
            let xRight: CGFloat = x + columnWidth / 2
            lastXRight = xRight
            
            let pointBottomLeft = CGPoint(x: xLeft, y: yLo)
            let pointBottomRight = CGPoint(x: xRight, y: yLo)
            let pointTopLeft = CGPoint(x: xLeft, y: yHi)
            let pointTopRight = CGPoint(x: xRight, y: yHi)
            
            var alpha = a
            if let sel = dataSource.selectedIndex {
                if i != sel {
                    alpha = tintAlpha
                }
            }
            
            newRenderData.append(RenderVertex(x: pointTopLeft.x, y: pointTopLeft.y, r: r, g: g, b: b, a: alpha))
            newRenderData.append(RenderVertex(x: pointTopRight.x, y: pointTopRight.y, r: r, g: g, b: b, a: alpha))
            newRenderData.append(RenderVertex(x: pointBottomRight.x, y: pointBottomRight.y, r: r, g: g, b: b, a: alpha))
            newRenderData.append(RenderVertex(x: pointBottomRight.x, y: pointBottomRight.y, r: r, g: g, b: b, a: alpha))
            newRenderData.append(RenderVertex(x: pointBottomLeft.x, y: pointBottomLeft.y, r: r, g: g, b: b, a: alpha))
            newRenderData.append(RenderVertex(x: pointTopLeft.x, y: pointTopLeft.y, r: r, g: g, b: b, a: alpha))
        }
        self.renderData = newRenderData
    }
}
