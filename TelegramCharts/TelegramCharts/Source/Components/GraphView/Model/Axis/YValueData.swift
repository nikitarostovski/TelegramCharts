//
//  YValueData.swift
//  TelegramCharts
//
//  Created by Rost on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YValueData {
    var lastOpacity: CGFloat
    var opacity: CGFloat
    var targetOpacity: CGFloat
    var value: CGFloat
    var text: String {
        return String(number: Int(value))
    }
    
    init(value: CGFloat) {
        self.value = value
        self.lastOpacity = 0
        self.opacity = 0
        self.targetOpacity = 1
    }
}
