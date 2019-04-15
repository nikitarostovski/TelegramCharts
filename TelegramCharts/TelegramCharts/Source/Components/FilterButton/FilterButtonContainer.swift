//
//  FilterButtonContainer.swift
//  TelegramCharts
//
//  Created by SBRF on 12/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class FilterButtonContainer: UIView {
    
    private let bottomInset: CGFloat = 16
    private let buttonSpacing: CGFloat = 8
    private let buttonHeight: CGFloat = 36
    
    var buttons = [FilterButton]() {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            buttons.forEach { addSubview($0) }
            invalidateIntrinsicContentSize()
        }
    }
    
    override func layoutSubviews() {
        layoutButtons()
        super.layoutSubviews()
    }
    
    override var intrinsicContentSize: CGSize {
        var s = super.intrinsicContentSize
        s.height = newHeight(forWidth: bounds.width)
        return s
    }
    
    func newHeight(forWidth width: CGFloat) -> CGFloat {
        guard width != 0, buttons.count > 0 else { return 0 }
        var totalWidth: CGFloat = 0
        buttons.forEach { button in
            button.sizeToFit()
            button.frame.size.width += 2 * buttonSpacing
            totalWidth += button.frame.width + buttonSpacing
        }
        totalWidth -= buttonSpacing
        let rowCount = Int(totalWidth / width) + 1
        return CGFloat(rowCount) * (buttonHeight) - buttonSpacing + bottomInset
    }
    
    private func layoutButtons() {
        var curRow: Int = 0
        var curX: CGFloat = 0
        buttons.forEach { button in
            button.sizeToFit()
            button.frame.size.width += 2 * buttonSpacing
            if curX + button.frame.width + buttonSpacing > bounds.width + buttonSpacing {
                curX = 0
                curRow += 1
            }
            button.frame = CGRect(x: curX, y: CGFloat(curRow) * (buttonHeight), width: button.frame.width, height: buttonHeight)
            curX += button.frame.width + buttonSpacing
        }
    }
}
