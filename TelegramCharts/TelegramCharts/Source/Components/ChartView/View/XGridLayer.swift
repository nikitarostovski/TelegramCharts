//
//  XGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol XGridLayerProtocol where Self: CALayer {
    
    func updatePoints(xPos: [CGFloat], dates: [Date])
}

class XGridLayer: CALayer, XGridLayerProtocol {

    private var xPositions = [CGFloat]()
    private var dates = [Date]()
    private var titleLayers = [TitleLayer]()
    
    override init() {
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePoints(xPos: [CGFloat], dates: [Date]) {
        self.xPositions = xPos
        self.dates = dates
    }
    
//    private func
    
    private func resetLayers() {
        
    }
    
    func themeDidUpdate(theme: Theme) {
    }
}

private class TitleLayer {
    
}
