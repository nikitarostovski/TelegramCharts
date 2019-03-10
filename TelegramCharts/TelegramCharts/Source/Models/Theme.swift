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
    
    var viewBackgroundColor: UIColor {
        switch style {
        case .day:
            return Colors.mediumGray
        case .night:
            return Colors.darkBlue
        }
    }
    
    var cellBackgroundColor: UIColor {
        switch style {
        case .day:
            return Colors.white
        case .night:
            return Colors.mediumBlue
        }
    }
    
    var tintColor: UIColor {
        switch style {
        case .day:
            return Colors.lightBlue
        case .night:
            return Colors.lightBlue
        }
    }
    
    var tableSeparatorColor: UIColor {
        switch style {
        case .day:
            return Colors.gray
        case .night:
            return Colors.veryDarkBlue
        }
    }
    
    var sectionTextColor: UIColor {
        switch style {
        case .day:
            return Colors.darkGray
        case .night:
            return Colors.blue
        }
    }
    
    var cellTextColor: UIColor {
        switch style {
        case .day:
            return Colors.black
        case .night:
            return Colors.white
        }
    }
    
    var navigationTintColor: UIColor {
        switch style {
        case .day:
            return Colors.black
        case .night:
            return Colors.white
        }
    }
    
    var navigationBackgroundColor: UIColor {
        switch style {
        case .day:
            return Colors.white
        case .night:
            return Colors.mediumBlue
        }
    }
}
