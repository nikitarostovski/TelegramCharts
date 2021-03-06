//
//  YTextLayer.swift
//  TelegramCharts
//
//  Created by SBRF on 12/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class YTextLayer: CALayer {
    
    private let textHeight: CGFloat = 16
    private var textColor: UIColor?
    
    private var titles: [CATextLayer]
    private var values: [YValueData]
    private weak var dataSource: YAxisDataSource?
    
    // MARK: - Lifecycle
    
    required init(source: YAxisDataSource) {
        self.dataSource = source
        self.textColor = source.color
        self.titles = []
        self.values = []
        super.init()
        masksToBounds = false
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Public
    
    func resetValues() {
        guard let dataSource = dataSource,
            bounds != .zero
        else {
            return
        }
        titles.forEach { $0.removeFromSuperlayer() }
        titles = []
        values = dataSource.values + dataSource.lastValues
        for source in values {
            let titleFrame = CGRect(x: 2, y: 0, width: bounds.width - 4, height: textHeight)
            let normY = (source.value - dataSource.viewport.yLo) / dataSource.viewport.height
            let titleLayer = CATextLayer()
            titleLayer.frame = titleFrame
            titleLayer.position.y = (1 - normY) * bounds.height - textHeight / 2
            titleLayer.opacity = Float(source.opacity)
            titleLayer.contentsScale = UIScreen.main.scale
            titleLayer.fontSize = 12
            titleLayer.foregroundColor = textColor?.cgColor
            titleLayer.alignmentMode = textAlignment
            titleLayer.string = source.text
            titles.append(titleLayer)
            addSublayer(titleLayer)
        }
//        updatePositions()
    }
    
    func updatePositions() {
        guard let dataSource = dataSource,
            bounds != .zero
            else {
                return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        titles.indices.forEach { i in
            let title = titles[i]
            title.opacity = Float(values[i].opacity)
            
            let normY = (values[i].value - dataSource.viewport.yLo) / dataSource.viewport.height
            title.position.y = (1 - normY) * bounds.height - textHeight / 2
        }
        CATransaction.commit()
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
