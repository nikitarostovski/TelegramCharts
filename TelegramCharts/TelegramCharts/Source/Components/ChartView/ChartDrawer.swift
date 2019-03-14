//
//  ChartDrawer.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawer {

    static func drawChart(points: [CGPoint], context: CGContext, color: CGColor, lineWidth: CGFloat = 1.0) {
        guard points.count > 1 else { return }
        context.saveGState()

        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setLineWidth(lineWidth)
        context.setFillColor(UIColor.clear.cgColor)
        context.setStrokeColor(color)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)

        context.move(to: points.first!)
        for i in 1 ..< points.count {
            context.addLine(to: points[i])
        }
        context.strokePath()

        context.restoreGState()
    }
}
