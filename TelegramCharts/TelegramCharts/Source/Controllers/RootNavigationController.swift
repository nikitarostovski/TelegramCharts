//
//  RootNavigationController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController, Stylable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startReceivingThemeUpdates()
        navigationBar.isTranslucent = false
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    func themeDidUpdate(theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()
        navigationBar.tintColor = theme.navigationTintColor
        navigationBar.barTintColor = theme.navigationBackgroundColor
        navigationBar.titleTextAttributes = [.foregroundColor: theme.navigationTintColor]
    }
}
