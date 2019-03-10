//
//  Theme.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum ThemeStyle {
    case regular
    case night
}

struct Theme {
    
    var style = ThemeStyle.regular
    
    var backgroundColor: UIColor {
        switch style {
        case .regular:
            return Colors.mediumGray
        case .night:
            return Colors.darkGray
        }
    }
    
    var tintColor: UIColor {
        switch style {
        case .regular:
            return Colors.lightBlue
        case .night:
            return Colors.lightBlue
        }
    }
}
