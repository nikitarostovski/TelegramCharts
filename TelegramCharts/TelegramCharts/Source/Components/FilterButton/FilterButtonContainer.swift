//
//  FilterButtonContainer.swift
//  TelegramCharts
//
//  Created by SBRF on 12/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class FilterButtonContainer: UIView {
    
    private let buttonSpacing: CGFloat = 8
    private let buttonHeight: CGFloat = 44
    
    var buttons = [UIButton]() {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            buttons.forEach { addSubview($0) }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.height = newHeight(forWidth: frame.width)
        layoutButtons()
    }
    
    override var intrinsicContentSize: CGSize {
        var s = super.intrinsicContentSize
        s.height = newHeight(forWidth: s.width)
        return s
    }
    
    private func newHeight(forWidth width: CGFloat) -> CGFloat {
        var totalWidth: CGFloat = 0
        buttons.forEach { button in
            button.sizeToFit()
            totalWidth += button.frame.width + buttonSpacing
        }
        totalWidth -= buttonSpacing
        let rowCount = Int(totalWidth / width) + 1
        return CGFloat(rowCount) * (buttonHeight + buttonSpacing) - buttonSpacing
    }
    
    private func layoutButtons() {
        var curRow: Int = 0
        var curX: CGFloat = 0
        buttons.forEach { button in
            button.sizeToFit()
            if button.frame.width + buttonSpacing > bounds.width + buttonSpacing {
                curX = 0
                curRow += 1
            }
            print(curRow)
            button.frame = CGRect(x: curX, y: CGFloat(curRow) * buttonHeight, width: button.frame.width, height: buttonHeight)
            curX += button.frame.width + buttonSpacing
        }
    }
}
