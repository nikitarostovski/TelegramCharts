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
    var textLeft: String?
    var textRight: String?
    
    var leftColor: UIColor?
    var rightColor: UIColor?
    
    init(textLeft: String?, textRight: String?, pos: CGFloat) {
        self.textLeft = textLeft
        self.textRight = textRight
        self.pos = pos
    }
}
