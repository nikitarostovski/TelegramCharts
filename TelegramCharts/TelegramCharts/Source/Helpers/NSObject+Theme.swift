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
                UIView.animate(withDuration: 0.15, animations: {
                    stylableSelf.themeDidUpdate(theme: theme)
                })
            }
        }
    }
    
    func stopReceivingThemeUpdates() {
        NotificationCenter.default.removeObserver(self)
    }
}
