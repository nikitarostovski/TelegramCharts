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
            return Colors.mediumGrayBlue.withAlphaComponent(0.90)
        case .night:
            return Colors.grayBlue.withAlphaComponent(0.90)
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
    
    var chartTitlesColor: UIColor {
        switch self {
        case .day:
            return Colors.gray
        case .night:
            return Colors.grayBlue
        }
    }
    
    var chartGridMainColor: UIColor {
        switch self {
        case .day:
            return Colors.gridLightMain
        case .night:
            return Colors.gridDarkMain
        }
    }
    
    var chartGridAuxColor: UIColor {
        switch self {
        case .day:
            return Colors.gridLightAux
        case .night:
            return Colors.gridDarkAux
        }
    }
}
