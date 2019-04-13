//
//  XAxisDataSource.swift
//  TelegramCharts
//
//  Created by Rost on 13/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class XAxisDataSource {
    var viewport: Viewport
    private (set) var lo: Int
    private (set) var hi: Int
    private (set) var values: [XValueData]
    
    private var lastStep: Int = 1
    
    private (set) var textFormat: DateFormat
    var textWidth: CGFloat {
        didSet {
            updatePoints()
        }
    }
    
    init(dates: [Date], viewport: Viewport) {
        let textFormat = DateFormat.dayMonth
        self.textFormat = textFormat
        self.viewport = viewport
        self.values = dates.indices.map {
            XValueData(x: CGFloat($0) / CGFloat(dates.count - 1), date: dates[$0], format: textFormat)
        }
        self.lo = 0
        self.hi = 0
        textWidth = 0
    }
    
    func updateViewportX(range: ClosedRange<CGFloat>) {
        viewport.xLo = range.lowerBound
        viewport.xHi = range.upperBound
        
        let lastIndex = values.count - 1
        
        lo = Int(viewport.xLo * CGFloat(lastIndex) - 0.5)
        hi = Int(viewport.xHi * CGFloat(lastIndex) + 0.5)
        lo = max(lo, 0)
        hi = min(hi, lastIndex)
        
        updatePoints()
    }
    
    private func updatePoints() {
        updateScale()
        let lastIndex = values.count - 1
        for i in values.indices {
            guard i >= lo, i <= hi else {
                values[i].isHidden = true
                continue
            }
            let xNorm = CGFloat(i) / CGFloat(lastIndex)
            values[i].x = xNorm
            values[i].isHidden = (lastIndex - i) % lastStep != 0
        }
    }
    
    private func updateScale() {
        guard textWidth > 0 else { return }
        let targetVisibleTitlesCount = max(1, Int(CGFloat(1) / textWidth))
        let scale = viewport.width
        let newStep = max(1, Int(CGFloat(values.count) * scale / CGFloat(targetVisibleTitlesCount)))
        
        var i = 1
        var newStepClamped = 1
        while newStepClamped < newStep {
            newStepClamped = Int(pow(Float(2), Float(i)))
            i += 1
        }
        if newStepClamped != lastStep {
            lastStep = newStepClamped
        }
    }
}
