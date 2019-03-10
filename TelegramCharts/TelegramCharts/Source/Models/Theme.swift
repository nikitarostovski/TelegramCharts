//
//  Theme.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum ThemeStyle {
    case day
    case night
}

struct Theme {
    
    var style: ThemeStyle
    
    init(style: ThemeStyle) {
        self.style = style
    }
    
    var backgroundColor: UIColor {
        switch style {
        case .day:
            return Colors.mediumGray
        case .night:
            return .red
        }
    }
    
    var tintColor: UIColor {
        switch style {
        case .day:
            return Colors.lightBlue
        case .night:
            return .red
        }
    }
    
    var tableSeparatorColor: UIColor {
        switch style {
        case .day:
            return Colors.gray
        case .night:
            return .red
        }
    }
    
    var sectionTextColor: UIColor {
        switch style {
        case .day:
            return Colors.darkGray
        case .night:
            return .red
        }
    }
}
