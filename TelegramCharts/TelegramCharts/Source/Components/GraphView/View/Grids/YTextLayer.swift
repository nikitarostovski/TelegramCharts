//
//  YTextLayer.swift
//  TelegramCharts
//
//  Created by SBRF on 12/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YTextLayer: CALayer {
    
    private var titles: [CATextLayer]
    private weak var dataSource: YAxisDataSource?
    
    private var textColor: UIColor?
    
    // MARK: - Lifecycle
    
    required init(source: YAxisDataSource) {
        self.dataSource = source
        self.textColor = source.color
        self.titles = []
        super.init()
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Public
    
    func update() {
        guard let dataSource = dataSource,
            bounds != .zero
            else {
                return
        }
        sublayers?.forEach { $0.removeFromSuperlayer() }
        let textHeight: CGFloat = 14
        for source in dataSource.lines {
            let y = (1 - source.pos) * bounds.height - textHeight
            let titleLayer = CATextLayer()
            titleLayer.frame = CGRect(x: 0, y: y, width: bounds.width, height: textHeight)
            titleLayer.contentsScale = UIScreen.main.scale
            titleLayer.fontSize = 12
            titleLayer.foregroundColor = textColor?.cgColor
            titleLayer.alignmentMode = textAlignment
            titleLayer.string = source.text
            addSublayer(titleLayer)
        }
    }
    
    // MARK: - Private
    
    private var textAlignment: CATextLayerAlignmentMode {
        switch dataSource!.alignment {
        case .fill, .left:
            return .left
        case .right:
            return .right
        }
    }
}

extension YTextLayer: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        if let color = dataSource?.color {
            textColor = color
        } else {
            textColor = theme.axisTextColor
        }
        titles.forEach { $0.foregroundColor = textColor?.cgColor }
    }
}
