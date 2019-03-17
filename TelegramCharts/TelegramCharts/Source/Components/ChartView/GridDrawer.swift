//
//  GridDrawer.swift
//  TelegramCharts
//
//  Created by Rost on 16/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GridDrawer {
    
    static func configureContext(context: CGContext, lineWidth: CGFloat = 1.0) {
        context.setLineCap(.butt)
        context.setLineJoin(.bevel)
        context.setLineWidth(lineWidth)
        context.setFillColor(UIColor.clear.cgColor)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
    }
    
    static func drawLine(pointA: CGPoint, pointB: CGPoint, color: CGColor, context: CGContext) {
        context.saveGState()
        
        context.setStrokeColor(color)
        context.move(to: pointA)
        context.addLine(to: pointB)
        context.strokePath()
        
        context.restoreGState()
    }
}
