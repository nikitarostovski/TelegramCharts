//
//  ChartLine.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 18/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartLine {

    var isHidden = false {
        didSet {
            targetAlpha = isHidden ? 0 : 1
        }
    }
    private var targetAlpha: CGFloat = 1
    var currentAlpha: CGFloat = 1

    var name: String
    var color: UIColor
    var x: [CGFloat]
    var y: [CGFloat]
    var values: [Int]

    init(values: [Int], color: UIColor, name: String) {
        self.x = [CGFloat]()
        for i in values.indices {
            self.x.append(CGFloat(i) / CGFloat(values.count - 1))
        }
        let maxValue = values.max() ?? 0
        self.values = values
        self.y = values.map { CGFloat($0) / CGFloat(maxValue) }
        self.color = color
        self.name = name
    }
}
