//
//  ChartViewRenderer.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 14/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartViewRenderer {

    static func configureContext(context: CGContext, lineWidth: CGFloat = 1.0, fillColor: CGColor = UIColor.clear.cgColor) {
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setLineWidth(lineWidth)
        context.setFillColor(fillColor)
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

    static func drawSelectionCircle(point: CGPoint, color: CGColor, radius: CGFloat, context: CGContext) {
        context.setStrokeColor(color)
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: 2 * radius, height: 2 * radius)
        context.addEllipse(in: rect)
        context.drawPath(using: .fillStroke)
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
