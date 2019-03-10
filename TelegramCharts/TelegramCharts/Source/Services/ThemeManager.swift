//
//  ThemeManager.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ThemeManager {
    
    static let themeChangeNotificationKey = "themeChanged"
    static let shared = ThemeManager()
    
    private let currentThemeKey = "currentTheme"
    
    var currentTheme: Theme {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(currentTheme.style.rawValue, forKey: currentThemeKey)
            defaults.synchronize()
            
            let name = NSNotification.Name(rawValue: ThemeManager.themeChangeNotificationKey)
            NotificationCenter.default.post(name: name, object: currentTheme)
        }
    }
    
    init() {
        let defaults = UserDefaults.standard
        let savedValue = defaults.integer(forKey: currentThemeKey)
        if let style = ThemeStyle(rawValue: savedValue) {
            currentTheme = Theme(style: style)
        } else {
            currentTheme = Theme(style: .day)
        }
    }
}
