//
//  XValueData.swift
//  TelegramCharts
//
//  Created by Rost on 13/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class XValueData {
    var date: Date
    var text: String
    var x: CGFloat
    
    var isHidden: Bool
    
    init(x: CGFloat, date: Date, format: DateFormat) {
        self.x = x
        self.isHidden = false
        self.date = date
        self.text = date.string(format: format)
    }
}
