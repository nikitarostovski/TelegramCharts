//
//  AxisData.swift
//  TelegramCharts
//
//  Created by Rost on 16/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class AxisData {
    var visibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            normalize()
        }
    }
    
    var xPoints: [XAxisData]
    
    init(xTitles: [String]) {
        self.xPoints = [XAxisData]()
        for i in 0 ..< xTitles.count {
            let x = CGFloat(i) / CGFloat(xTitles.count)
            xPoints.append(XAxisData(x: x, title: xTitles[i]))
        }
    }
    
    func updateAlpha(phase: CGFloat) {
        xPoints.forEach { $0.updateAlpha(phase: phase) }
    }
    
    private func normalize() {
        xPoints.forEach { $0.normalize(range: visibleRange) }
    }
    
    func getTextToDraw(viewport: CGRect) -> [XAxisData] {
        for point in xPoints {
            point.targetAlpha = isVisible(point: point) ? 1 : 0
            let x = viewport.origin.x + point.normX * viewport.width
            point.dispX = x
        }
        return xPoints
    }
    
    private func isVisible(point: XAxisData) -> Bool {
        return point.normX > 0.2 && point.normX < 0.7
    }
}

class XAxisData {
    var x: CGFloat
    var title: String
    var targetAlpha: CGFloat = 1
    var currentAlpha: CGFloat = 1
    
    var normX: CGFloat = 0
    var dispX: CGFloat = 0
    
    init(x: CGFloat, title: String) {
        self.x = x
        self.title = title
    }
    
    func updateAlpha(phase: CGFloat) {
        currentAlpha = currentAlpha + (targetAlpha - currentAlpha) * phase
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        normX = (x - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}
