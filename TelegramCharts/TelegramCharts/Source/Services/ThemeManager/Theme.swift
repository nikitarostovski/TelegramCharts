//
//  Theme.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum Theme: Int {
    case day = 100
    case night = 101

    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .day:
            return .default
        case .night:
            return .lightContent
        }
    }

    var viewBackgroundColor: UIColor {
        switch self {
        case .day:
            return Colors.mediumGray
        case .night:
            return Colors.darkBlue
        }
    }

    var cellBackgroundColor: UIColor {
        switch self {
        case .day:
            return Colors.white
        case .night:
            return Colors.mediumBlue
        }
    }

    var tintColor: UIColor {
        switch self {
        case .day:
            return Colors.lightBlue
        case .night:
            return Colors.lightBlue
        }
    }

    var tableSeparatorColor: UIColor {
        switch self {
        case .day:
            return Colors.gray
        case .night:
            return Colors.veryDarkBlue
        }
    }

    var sectionTextColor: UIColor {
        switch self {
        case .day:
            return Colors.darkGray
        case .night:
            return Colors.blue
        }
    }

    var cellSelectionColor: UIColor {
        switch self {
        case .day:
            return Colors.black.withAlphaComponent(0.1)
        case .night:
            return Colors.black.withAlphaComponent(0.1)
        }
    }
    
    var cellTextColor: UIColor {
        switch self {
        case .day:
            return Colors.black
        case .night:
            return Colors.white
        }
    }

    var navigationTintColor: UIColor {
        switch self {
        case .day:
            return Colors.black
        case .night:
            return Colors.white
        }
    }

    var navigationBackgroundColor: UIColor {
        switch self {
        case .day:
            return Colors.white
        case .night:
            return Colors.mediumBlue
        }
    }
    
    var sliderThumbColor: UIColor {
        switch self {
        case .day:
            return UIColor(hexString: "c0d1e1")
        case .night:
            return UIColor(hexString: "56626d")
        }
    }
    
    var sliderTintColor: UIColor {
        switch self {
        case .day:
            return Colors.lightGrayBlue.withAlphaComponent(0.75)
        case .night:
            return Colors.darkGrayBlue.withAlphaComponent(0.75)
        }
    }
    
    var sliderThumbArrowColor: UIColor {
        switch self {
        case .day:
            return Colors.white
        case .night:
            return Colors.white
        }
    }
    
    var axisTextColor: UIColor {
        switch self {
        case .day:
            return UIColor(hexString: "252529").withAlphaComponent(0.5)
        case .night:
            return UIColor(hexString: "BACCE1").withAlphaComponent(0.6)
        }
    }
    
    var gridLineColor: UIColor {
        switch self {
        case .day:
            return UIColor(hexString: "182D3B").withAlphaComponent(0.1)
        case .night:
            return UIColor(hexString: "8596AB").withAlphaComponent(0.2)
        }
    }
    
    var selectionBackColor: UIColor {
        switch self {
        case .day:
            return Colors.lightGray
        case .night:
            return Colors.darkGrayBlue
        }
    }
    
    var selectionTextColor: UIColor {
        switch self {
        case .day:
            return Colors.darkGray
        case .night:
            return Colors.white
        }
    }
}
