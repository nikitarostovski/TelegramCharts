//
//  YValueData.swift
//  TelegramCharts
//
//  Created by Rost on 11/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YValueData {
    var pos: CGFloat
    var text: String?
    
    init(text: String, pos: CGFloat) {
        self.text = text
        self.pos = pos
    }
}
