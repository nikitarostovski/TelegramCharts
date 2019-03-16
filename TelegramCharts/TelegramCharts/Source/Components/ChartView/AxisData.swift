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
    
    private func normalize() {
        xPoints.forEach { $0.normalize(range: visibleRange) }
    }
    
    func getTextToDraw(viewport: CGRect) -> [(CGPoint, String)] {
        var result = [(CGPoint, String)]()
        for point in xPoints {
            let x = viewport.origin.x + point.dispX * viewport.width
            let y = viewport.height
            result.append((CGPoint(x: x, y: y), point.title))
        }
        return result
    }
}

class XAxisData {
    var x: CGFloat
    var title: String
    
    var dispX: CGFloat = 0
    
    init(x: CGFloat, title: String) {
        self.x = x
        self.title = title
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        dispX = (x - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}
