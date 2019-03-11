//
//  RootNavigationController.swift
//  TelegramCharts
//
//  Created by Rost on 10/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startReceivingThemeUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopReceivingThemeUpdates()
    }
}

extension RootNavigationController: Stylable {

    func themeDidUpdate(theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()
        navigationBar.tintColor = theme.navigationTintColor
        navigationBar.barTintColor = theme.navigationBackgroundColor
        navigationBar.titleTextAttributes = [.foregroundColor: theme.navigationTintColor]
    }
}
