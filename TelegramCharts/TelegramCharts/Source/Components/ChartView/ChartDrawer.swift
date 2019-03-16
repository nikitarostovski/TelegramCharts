//
//  ChartDrawer.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawer {

    static func configureContext(context: CGContext, lineWidth: CGFloat = 1.0) {
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setLineWidth(lineWidth)
        context.setFillColor(UIColor.clear.cgColor)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
    }

    static func drawChart(points: [CGPoint], color: CGColor, context: CGContext) {
        guard points.count > 1 else { return }
        context.saveGState()

        context.setStrokeColor(color)
        context.move(to: points.first!)
        for i in 1 ..< points.count {
            context.addLine(to: points[i])
        }
        context.strokePath()

        context.restoreGState()
    }
}
