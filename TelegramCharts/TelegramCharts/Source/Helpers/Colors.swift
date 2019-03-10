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
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
    
    static let white = UIColor(hexString: "fefefe")
    static let black = UIColor(hexString: "000")
    
}
