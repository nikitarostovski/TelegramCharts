//
//  MetalChartsView.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import MetalKit

class MetalChartsView: MTKView, ChartViewProtocol, RenderDataSource {
    
    private var isMap: Bool
    private var lineWidth: CGFloat
    private var providers: [MetalDataProvider]
    
    internal var renderData: [RenderVertex]
    private var renderer: Renderer!
    
    init(dataSource: GraphDataSource, isMap: Bool, lineWidth: CGFloat) {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        self.isMap = isMap
        self.lineWidth = lineWidth
        self.renderData = []
        self.providers = [MetalDataProvider]()
        
        super.init(frame: .zero, device: defaultDevice)
        backgroundColor = .clear
        sampleCount = 4
        layer.masksToBounds = false
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        createRenderer(device: defaultDevice)
        
        dataSource.chartDataSources.forEach {
            if let provider = providerForChart($0) {
                providers.append(provider)
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createRenderer(device: MTLDevice) {
        renderer = Renderer(device: device)
        renderer.dataSource = self
        delegate = renderer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let convertedLine = lineWidth / UIScreen.main.bounds.width
        for i in providers.indices {
            providers[i].lineWidth = convertedLine
        }
        update()
    }
    
    func update() {
        guard bounds != .zero else { return }
        providers.forEach { $0.update() }
        var newRenderData = [RenderVertex]()
        providers.forEach { newRenderData += $0.renderData }
        self.renderData = newRenderData
    }
    
    private func providerForChart(_ source: ChartDataSource) -> MetalDataProvider? {
        switch source.chart.type {
        case .line:
            return MetalLineDataProvider(source: source, lineWidth: lineWidth, isMap: isMap)
        case .bar:
            return MetalBarDataProvider(source: source, lineWidth: lineWidth, isMap: isMap)
        case .area:
            return MetalAreaDataProvider(source: source, lineWidth: lineWidth, isMap: isMap)
        }
    }
}
