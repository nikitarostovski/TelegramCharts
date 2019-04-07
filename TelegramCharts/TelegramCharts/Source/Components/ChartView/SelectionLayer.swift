//
//  SelectionLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum SelectionStyle {
    case lineChart
}

struct SelectionData {
    var date: Date?
    var format: DateFormat?
    var values: [Int]
    var colors: [UIColor]
    var titles: [String]
}

protocol SelectionLayerProtocol: CALayer {
    
    func setData(data: SelectionData)
    func show(x: CGFloat)
    func move(toX x: CGFloat)
    func hide()
}

class SelectionLayer: CALayer, SelectionLayerProtocol {
    
    private var data: SelectionData?
    
    private var lineLayer: CAShapeLayer?
    private var pointsLayers: [CAShapeLayer]?
    
    private var plateLayer: CAShapeLayer
    private var titleLayer: CATextLayer?
    private var valuesLayers: [CATextLayer]
    private var titlesLayers: [CATextLayer]
    
    private var plateColor: UIColor = .white
    private var titleColor: UIColor = .black
    private var textColor: UIColor = .darkGray
    private var gridColor: UIColor = .darkGray
    
    private let topInset: CGFloat = 6
    private let lineSpacing: CGFloat = 2
    private let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    
    private var viewStyle: SelectionStyle
    
    init(style: SelectionStyle) {
        self.viewStyle = style
        plateLayer = CAShapeLayer()
        plateLayer.cornerRadius = 6
        plateLayer.masksToBounds = true
        
        valuesLayers = [CATextLayer]()
        titlesLayers = [CATextLayer]()
        pointsLayers = [CAShapeLayer]()
        
        super.init()
        
        if viewStyle == .lineChart {
            lineLayer = CAShapeLayer()
            addSublayer(lineLayer!)
        }
        addSublayer(plateLayer)
        
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        if let lineLayer = lineLayer {
            lineLayer.frame.size = CGSize(width: 1, height: bounds.height)
        }
    }
    
    func setData(data: SelectionData) {
        self.data = data
        update()
    }
    
    func show(x: CGFloat) {
        isHidden = false
        let x = x * bounds.size.width - plateLayer.frame.size.width / 2
        plateLayer.frame.origin = CGPoint(x: x, y: topInset)
        lineLayer?.frame.origin = CGPoint(x: x, y: 0)
    }
    
    func move(toX x: CGFloat) {
        let x = x * bounds.size.width - plateLayer.frame.size.width / 2
        plateLayer.frame.origin = CGPoint(x: x, y: topInset)
        lineLayer?.frame.origin = CGPoint(x: x, y: 0)
    }
    
    func hide() {
        isHidden = true
    }
    
    private func update() {
        let spacing: CGFloat = 4
        plateLayer.backgroundColor = plateColor.cgColor

        titleLayer?.removeFromSuperlayer()
        titleLayer = nil
        valuesLayers.forEach { $0.removeFromSuperlayer() }
        titlesLayers.forEach { $0.removeFromSuperlayer() }
        valuesLayers = []
        titlesLayers = []
        
        guard let data = data else { return }
        var totalWidth: CGFloat = insets.left
        var totalHeight: CGFloat = insets.top
        
        var leftColumnWidth: CGFloat = 0
        
        if let date = data.date, let format = data.format {
            let titleText = date.string(format: format)
            let layer = makeTitleLayer()
            layer.string = titleText
            layer.frame.origin = CGPoint(x: insets.left, y: insets.top)
            layer.frame.size = layer.preferredFrameSize()
            
            totalWidth += layer.frame.size.width
            totalHeight += layer.frame.size.height + lineSpacing
            titleLayer = layer
            plateLayer.addSublayer(layer)
        }
        
        for i in data.values.indices {
            let title = data.titles[i]
            
            let layer = makeTextLayer(color: textColor, font: textFont)
            layer.string = title
            layer.frame.size = layer.preferredFrameSize()
            self.titlesLayers.append(layer)
            plateLayer.addSublayer(layer)
            leftColumnWidth = max(leftColumnWidth, layer.frame.size.width)
        }
        leftColumnWidth += spacing
        
        var rightColumnWidth: CGFloat = 0
        for i in data.values.indices {
            let value = data.values[i]
            let color = data.colors[i]
            
            let layer = makeTextLayer(color: color, alignment: .right, font: valueFont)
            layer.string = String(decimal: value)
            layer.frame.size = layer.preferredFrameSize()
            self.valuesLayers.append(layer)
            plateLayer.addSublayer(layer)
            rightColumnWidth = max(rightColumnWidth, layer.frame.size.width)
        }
        
        totalWidth = max(totalWidth, leftColumnWidth + rightColumnWidth) + insets.right
        
        var leftColumnHeight: CGFloat = 0
        for l in titlesLayers {
            l.frame.origin = CGPoint(x: insets.left, y: leftColumnHeight + totalHeight)
            leftColumnHeight += l.frame.size.height + lineSpacing
        }
        
        var rightColumnHeight: CGFloat = 0
        for l in valuesLayers {
            l.frame.origin = CGPoint(x: totalWidth - rightColumnWidth - insets.right, y: rightColumnHeight + totalHeight)
            l.frame.size.width = rightColumnWidth
            rightColumnHeight += l.frame.size.height + lineSpacing
        }
        totalHeight = totalHeight + max(leftColumnHeight, rightColumnHeight) + insets.bottom - lineSpacing
        plateLayer.frame.size = CGSize(width: totalWidth, height: totalHeight)
    }
    
    private func makeTitleLayer() -> CATextLayer {
        let titleLayer = CATextLayer()
        titleLayer.font = makeFontRef(font: titleFont)
        titleLayer.fontSize = titleFont.pointSize
        titleLayer.contentsScale = UIScreen.main.scale
        titleLayer.foregroundColor = titleColor.cgColor
        return titleLayer
    }
    
    private func makeTextLayer(color: UIColor, alignment: CATextLayerAlignmentMode = .left, font: UIFont) -> CATextLayer {
        let layer = CATextLayer()
        layer.font = makeFontRef(font: font)
        layer.alignmentMode = alignment
        layer.foregroundColor = color.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.fontSize = font.pointSize
        return layer
    }
    
    private var titleFont = UIFont.systemFont(ofSize: 12, weight: .bold)
    private var textFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    private var valueFont = UIFont.systemFont(ofSize: 12, weight: .bold)
    
    private func makeFontRef(font: UIFont) -> CFTypeRef {
        return CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
    }
}

extension SelectionLayer: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        plateColor = theme.selectionBackColor
        titleColor = theme.selectionTextColor
        textColor = theme.selectionTextColor
        gridColor = theme.chartGridMainColor
        
        plateLayer.fillColor = plateColor.cgColor
        if let titleLayer = titleLayer {
            titleLayer.foregroundColor = titleColor.cgColor
        }
        for l in titlesLayers {
            l.foregroundColor = textColor.cgColor
        }
        if let lineLayer = lineLayer {
            lineLayer.strokeColor = gridColor.cgColor
        }
    }
}
