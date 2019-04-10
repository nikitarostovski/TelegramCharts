//
//  ChartViewport.swift
//  TelegramCharts
//
//  Created by Rost on 10/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartViewport {
    
    var xLo: CGFloat = 0
    var xHi: CGFloat = 0
    var yLo: CGFloat = 0
    var yHi: CGFloat = 0
    
    var width: CGFloat {
        return xHi - xLo
    }
    
    var height: CGFloat {
        return yHi - yLo
    }
    
    /*private (set) var current: CGRect
    private (set) var last: CGRect
    var target: CGRect {
        didSet {
            current = target
        }
    }
    
    init(rect: CGRect) {
        last = rect
        current = rect
        target = rect
    }*/
}


extension ChartViewport: CustomStringConvertible {
    
    var description : String {
        return "X: [\(xLo) ... \(xHi)] Y: [\(yLo) ... \(yHi)]"
    }
}
