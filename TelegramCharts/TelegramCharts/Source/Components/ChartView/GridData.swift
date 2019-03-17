//
//  GridData.swift
//  TelegramCharts
//
//  Created by Rost on 17/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GridData {
    var maxVisibleValue: Int64 = 0 {
        didSet {
            normalize()
        }
    }
    private var maxValue: Int64 = 0
    var sectionHeight: CGFloat = 100
    var maxVisibleSections = 5
    
    private var yLines = [GridLineData]()
    
    init(maxY: Int64) {
        self.maxValue = maxY
        for i in 0 ..< maxValue {
            let line = GridLineData(y: CGFloat(i) / CGFloat(maxValue), value: i)
            yLines.append(line)
        }
    }
    
    func updateAlpha(phase: CGFloat) {
        yLines.forEach { $0.updateAlpha(phase: phase) }
    }
    
    private func normalize() {
        yLines.forEach {
            let range = CGFloat(0) ... CGFloat(maxVisibleValue) / CGFloat(maxValue)
            $0.normalize(range: range)
        }
        
        let bottomIndex = 0
        var topIndex = 0
        for i in 1 ..< yLines.count {
            if yLines[i].normY > 1 {
                topIndex = i - 1
                break
            }
        }
        var step = 1
        var visibleCount = topIndex - bottomIndex + 1
        while visibleCount > maxVisibleSections {
            step += 1
            visibleCount = (topIndex - bottomIndex + 1) / step
        }
        var visibilityIterator = 0
        for i in yLines.indices {
            if i == bottomIndex || i == topIndex {
                yLines[i].isHidden = false
                yLines[i].targetAlpha = 1
                yLines[i].currentAlpha = 1
            } else if i < bottomIndex || i > topIndex {
                yLines[i].isHidden = true
                yLines[i].targetAlpha = 0
                yLines[i].currentAlpha = 0
            } else {
                yLines[i].isHidden = false
                if visibilityIterator == step {
                    yLines[i].targetAlpha = 1
                } else {
                    yLines[i].targetAlpha = 0
                }
                visibilityIterator += 1
                if visibilityIterator > step {
                    visibilityIterator = 0
                }
            }
        }
    }
    
    func getLinesToDraw(viewport: CGRect) -> [GridLineData] {
        for line in yLines {
            guard !line.isHidden else { continue }
            let y = viewport.origin.y + viewport.height - (line.normY * viewport.height)
            line.dispY = y
        }
        return yLines.filter { !$0.isHidden }
    }
}

class GridLineData {
    var y: CGFloat
    var value: Int64
    
    var isHidden = true
    var targetAlpha: CGFloat = 1
    var currentAlpha: CGFloat = 1
    
    var normY: CGFloat = 0
    var dispY: CGFloat = 0
    
    init(y: CGFloat, value: Int64) {
        self.y = y
        self.value = value
    }
    
    func updateAlpha(phase: CGFloat) {
        currentAlpha = currentAlpha + (targetAlpha - currentAlpha) * phase
    }
    
    func normalize(range: ClosedRange<CGFloat>) {
        normY = (y - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

