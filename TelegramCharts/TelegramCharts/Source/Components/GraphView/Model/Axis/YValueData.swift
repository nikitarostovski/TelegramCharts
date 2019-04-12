//
//  YValueData.swift
//  TelegramCharts
//
//  Created by Rost on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YValueData {
    var fadeLastPhase: CGFloat
    var fadePhase: CGFloat
    var fadeTargetPhase: CGFloat
    var value: CGFloat
    var text: String {
        return String(number: Int(value))
    }
    
    init(value: CGFloat) {
        self.value = value
        self.fadeLastPhase = 0
        self.fadePhase = 0
        self.fadeTargetPhase = 1
    }
}
