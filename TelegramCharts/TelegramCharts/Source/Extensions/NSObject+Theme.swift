//
//  qwe.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol Stylable {
    func themeDidUpdate(theme: Theme)
}

extension NSObject {
    
    func startReceivingThemeUpdates() {
        let name = NSNotification.Name(ThemeManager.themeChangeNotificationKey)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [weak self] (n) in
            guard let theme = n.object as? Theme else {
                return
            }
            if let stylableSelf = self as? Stylable {
//                let animationDuration = 0.15
                
//                CATransaction.begin()
//                CATransaction.setAnimationDuration(animationDuration)
                
//                UIView.animate(withDuration: animationDuration, animations: {
                    stylableSelf.themeDidUpdate(theme: theme)
//                })
                
//                CATransaction.commit()
            }
        }
        if let stylableSelf = self as? Stylable {
            stylableSelf.themeDidUpdate(theme: ThemeManager.shared.currentTheme)
        }
    }
    
    func stopReceivingThemeUpdates() {
        NotificationCenter.default.removeObserver(self)
    }
}
