//
//  Colors.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

struct Colors {
    
    static let lightGray = UIColor(hexString: "f7f7f7")
    static let mediumGray = UIColor(hexString: "efeff4")
    static let gray = UIColor(hexString: "c8c7cc")
    static let darkGray = UIColor(hexString: "6d6d72")
    
    static let lightBlue = UIColor(hexString: "007ee5")
    static let mediumBlue = UIColor(hexString: "212f3f")
    static let blue = UIColor(hexString: "5b6b7f")
    static let darkBlue = UIColor(hexString: "18222d")
    static let veryDarkBlue = UIColor(hexString: "121a23")
    
    static let darkGrayBlue = UIColor(hexString: "1c2938")
    static let grayBlue = UIColor(hexString: "37485c")
    static let mediumGrayBlue = UIColor(hexString: "c8d1db")
    static let lightGrayBlue = UIColor(hexString: "f2f5f7")
    
    static let white = UIColor(hexString: "fefefe")
    static let black = UIColor(hexString: "000")
    
    static let gridDarkMain = UIColor(hexString: "131b23")
    static let gridDarkAux = UIColor(hexString: "1b2734")
    static let gridLightMain = UIColor(hexString: "cfd1d2")
    static let gridLightAux = UIColor(hexString: "f3f3f3")
    static let gridDarkText = UIColor(hexString: "5d6d7e")
    static let gridLightText = UIColor(hexString: "989ea3")
    
}
