//
//  ChartDrawAxisX.swift
//  TelegramCharts
//
//  Created by Rost on 22/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartDrawAxisX {
    
    var visibleDatesCount = 5
    var points: [ChartDrawPointX]
    var selectionIndex: Int? {
        didSet {
            if let oldValue = oldValue {
                points[oldValue].isSelected = false
            }
            if let selectionIndex = selectionIndex {
                points[selectionIndex].isSelected = true
            }
        }
    }
    
    var firstIndex = 0 {
        didSet {
            updatePoints()
        }
    }
    var lastIndex = 0 {
        didSet {
            updatePoints()
        }
    }
    
    init(dates: [Date]) {
        self.points = [ChartDrawPointX]()
        for i in dates.indices {
            let x = CGFloat(i) / CGFloat(dates.count - 1)
            let point = ChartDrawPointX(value: dates[i], x: x)
            points.append(point)
        }
    }
    
    func getClosestIndex(position: CGFloat) -> Int {
        return Int(CGFloat(points.count) * position)
    }
    
    private func updatePoints() {
        
        //        let step = (finishIndex - startIndex)
        
        for i in points.indices {
            let pt = points[i]
            /*if i < startIndex || i > finishIndex {
             pt.isHidden = true
             continue
             }
             if i % step == 0 {
             pt.isHidden = false
             } else {
             pt.isHidden = true
             }*/
            pt.isHidden = false
        }
    }
}

class ChartDrawPointX {
    var originalX: CGFloat
    var x: CGFloat = 0
    var value: Date
    var title: String
    var alpha: CGFloat
    var isHidden = false
    var isSelected: Bool = false
    
    init(value: Date, x: CGFloat, initialAlpha: CGFloat = 1) {
        self.originalX = x
        self.value = value
        self.title = value.monthDayShortString()
        self.alpha = initialAlpha
    }
}
