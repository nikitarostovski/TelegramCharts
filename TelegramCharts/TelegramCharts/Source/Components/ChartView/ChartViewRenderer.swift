//
//  ChartViewRenderer.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartViewRenderer {

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
        context.setStrokeColor(color)
        context.move(to: points.first!)
        for i in 1 ..< points.count {
            context.addLine(to: points[i])
        }
        context.strokePath()
    }

    static func drawLine(pointA: CGPoint, pointB: CGPoint, color: CGColor, context: CGContext) {
        context.setStrokeColor(color)
        context.move(to: pointA)
        context.addLine(to: pointB)
        context.strokePath()
    }

    static func drawText(text: NSAttributedString, frame: CGRect) {
        text.draw(in: frame)
    }
}
