//
//  AxisDrawer.swift
//  TelegramCharts
//
//  Created by Rost on 16/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class AxisDrawer {
    
    static func configureContext(context: CGContext) {
        context.setFillColor(UIColor.clear.cgColor)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
    }
    
    static func drawText(text: NSAttributedString, frame: CGRect) {
        text.draw(in: frame)
    }
}
