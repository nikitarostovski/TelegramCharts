//
//  MetalAreaDataProvider.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class MetalAreaDataProvider: MetalDataProvider {
    
    private weak var dataSource: AreaChartDataSource?
    private var isMap: Bool
    var lineWidth: CGFloat = 0
    var renderData: [RenderVertex]
    
    init(source: ChartDataSource, lineWidth: CGFloat, isMap: Bool) {
        guard let source = source as? AreaChartDataSource else { fatalError() }
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
        dataSource.chart.color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var newRenderData = [RenderVertex]()
        var yLoLast: CGFloat? = nil
        var yHiLast: CGFloat? = nil
        for i in startIndex ... finishIndex {
            let x = CGFloat(2) * (dataSource.xIndices[i] - viewport.xLo) / viewport.width - CGFloat(1)
            let yLo = CGFloat(2) - ((CGFloat(dataSource.yValues[i].offset) / CGFloat(dataSource.yValues[i].sumValue) - viewport.yLo) / viewport.height) * CGFloat(2) - CGFloat(1)
            let yHi = CGFloat(2) - ((CGFloat(dataSource.yValues[i].offset + dataSource.yValues[i].value) / CGFloat(dataSource.yValues[i].sumValue) - viewport.yLo) / viewport.height) * CGFloat(2) - CGFloat(1)
            
            if let yLoLast = yLoLast, let yHiLast = yHiLast {
                var xLeft: CGFloat
                if let lastXRight = lastXRight {
                    xLeft = lastXRight
                } else {
                    xLeft = x - columnWidth
                }
                let xRight: CGFloat = x
                
                let pointBottomLeft = CGPoint(x: xLeft, y: yLoLast)
                let pointBottomRight = CGPoint(x: xRight, y: yLo)
                let pointTopLeft = CGPoint(x: xLeft, y: yHiLast)
                let pointTopRight = CGPoint(x: xRight, y: yHi)
                
                newRenderData.append(RenderVertex(x: pointTopLeft.x, y: pointTopLeft.y, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: pointTopRight.x, y: pointTopRight.y, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: pointBottomRight.x, y: pointBottomRight.y, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: pointBottomRight.x, y: pointBottomRight.y, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: pointBottomLeft.x, y: pointBottomLeft.y, r: r, g: g, b: b, a: a))
                newRenderData.append(RenderVertex(x: pointTopLeft.x, y: pointTopLeft.y, r: r, g: g, b: b, a: a))
            }
            lastXRight = x
            yLoLast = yLo
            yHiLast = yHi
        }
        self.renderData = newRenderData
    }
}
