//
//  XGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol XGridLayerProtocol: CALayer {
    
    func updatePoints(xPos: [CGFloat], dates: [Date])
}

class XGridLayer: CALayer, XGridLayerProtocol {

    private var xPositions = [CGFloat]()
    private var dates = [Date]()
    private var titleLayers = [TitleLayer]()
    
    func updatePoints(xPos: [CGFloat], dates: [Date]) {
        self.xPositions = xPos
        self.dates = dates
        
    }
    
//    private func
    
    private func resetLayers() {
        
    }
}

private class TitleLayer {
    
}
