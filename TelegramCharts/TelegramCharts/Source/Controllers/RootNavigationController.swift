//
//  RootNavigationController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {
    
    var theme = Theme(style: .day) {
        didSet {
            updateAppearance()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
    }
    
    func updateAppearance() {
        setNeedsStatusBarAppearanceUpdate()
        navigationBar.tintColor = theme.navigationTintColor
        navigationBar.barTintColor = theme.navigationBackgroundColor
        navigationBar.titleTextAttributes = [.foregroundColor: theme.navigationTintColor]
    }
}
