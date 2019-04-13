//
//  XGridLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class XTextLayer: CALayer {
    
    private let cacheLimit: Int = 12
    
    private let textHeight: CGFloat = 16
    private let textWidth: CGFloat = 50
    private var textColor: UIColor = .white
    
    private var cachedTitles: [XValueLayer]
    private var titles: [XValueLayer]
    private weak var dataSource: XAxisDataSource?
    
    // MARK: - Lifecycle
    
    required init(source: XAxisDataSource) {
        self.dataSource = source
        self.cachedTitles = []
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
    
    func updatePositions() {
        guard bounds != .zero, let dataSource = dataSource else { return }
        resetValues()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        titles.forEach { title in
            title.position.x = bounds.width * (title.data.x - dataSource.viewport.xLo) / dataSource.viewport.width
            title.isHidden = title.data.isHidden
        }
        CATransaction.commit()
    }
    
    // MARK: - Private
    
    private func resetValues() {
        guard let dataSource = dataSource,
            bounds != .zero
            else {
                return
        }
        var titlesToRemove = [XValueLayer]()
        titles.forEach { title in
            if title.data.isHidden {
                title.removeFromSuperlayer()
                titlesToRemove.append(title)
            }
        }
        titlesToRemove.forEach { title in
            if cachedTitles.count <= cacheLimit {
                cachedTitles.append(title)
            }
            titles.removeAll(where: { title === $0 })
        }
        for i in dataSource.values.indices {
            let value = dataSource.values[i]
            guard !value.isHidden else { continue }
            guard titles.first(where: { $0.data === value }) == nil else {
                continue
            }
            let titleLayer = dequeueTitle(data: value)
            titles.append(titleLayer)
            addSublayer(titleLayer)
        }
    }
    
    private func dequeueTitle(data: XValueData) -> XValueLayer {
        if let cachedTitle = cachedTitles.first {
            cachedTitles.removeFirst()
            cachedTitle.data = data
            return cachedTitle
        }
        let x = data.x
        let y = (bounds.height - textHeight) / 2
        let titleFrame = CGRect(x: x * bounds.width, y: y, width: textWidth, height: textHeight)
        let titleLayer = XValueLayer(data: data)
        titleLayer.frame = titleFrame
        titleLayer.contentsScale = UIScreen.main.scale
        titleLayer.fontSize = 12
        titleLayer.foregroundColor = textColor.cgColor
        titleLayer.alignmentMode = .center
        return titleLayer
    }
}

extension XTextLayer: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        textColor = theme.axisTextColor
        titles.forEach { $0.foregroundColor = textColor.cgColor }
    }
}

class XValueLayer: CATextLayer {
    
    var data: XValueData {
        didSet {
            self.string = data.text
        }
    }
    
    required init(data: XValueData) {
        self.data = data
        super.init()
        self.string = data.text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
