//
//  SelectionLayer.swift
//  TelegramCharts
//
//  Created by Rost on 07/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

struct ChartSelectionData {
    var date: Date?
    var format: DateFormat?
    var values: [Int]
    var percents: [String]?
    var colors: [UIColor]
    var titles: [String]
}

class SelectionLayer: CALayer {
    
    private var data: ChartSelectionData?
    
    private (set) var plateLayer: CAShapeLayer
    private var titleLayer: CATextLayer?
    private var valuesLayers: [CATextLayer]
    private var titlesLayers: [CATextLayer]
    private var percentLayers: [CATextLayer]
    
    private var plateColor: UIColor = .white
    private var titleColor: UIColor = .black
    private var textColor: UIColor = .darkGray
    
    private let topInset: CGFloat = 6
    private let lineSpacing: CGFloat = 2
    private let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    
    override init() {
        plateLayer = CAShapeLayer()
        plateLayer.cornerRadius = 6
        plateLayer.masksToBounds = true
        
        valuesLayers = [CATextLayer]()
        titlesLayers = [CATextLayer]()
        percentLayers = [CATextLayer]()
        
        super.init()
        addSublayer(plateLayer)
        
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    func setData(data: ChartSelectionData, animated: Bool = true) {
        self.data = data
        update(animated: animated)
    }
    
    private func update(animated: Bool) {
        let spacing: CGFloat = 8
        plateLayer.backgroundColor = plateColor.cgColor

        titleLayer?.removeFromSuperlayer()
        titleLayer = nil
        valuesLayers.forEach { $0.removeFromSuperlayer() }
        titlesLayers.forEach { $0.removeFromSuperlayer() }
        percentLayers.forEach { $0.removeFromSuperlayer() }
        valuesLayers = []
        titlesLayers = []
        percentLayers = []
        
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
        
        var percentColumnWidth: CGFloat = 0
        if let percents = data.percents {
            for i in percents.indices {
                let title = percents[i]
                
                let layer = makeTextLayer(color: titleColor, alignment: .right, font: titleFont)
                layer.string = title
                layer.frame.size = layer.preferredFrameSize()
                self.percentLayers.append(layer)
                plateLayer.addSublayer(layer)
                percentColumnWidth = max(percentColumnWidth, layer.frame.size.width)
            }
            percentColumnWidth += spacing
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
        
        totalWidth = max(totalWidth, leftColumnWidth + rightColumnWidth + percentColumnWidth + spacing + insets.left) + insets.right
        
        var percentColumnHeight: CGFloat = 0
        for l in percentLayers {
            l.frame.origin = CGPoint(x: insets.left, y: percentColumnHeight + totalHeight)
            l.frame.size.width = percentColumnWidth - spacing
            percentColumnHeight += l.frame.size.height + lineSpacing
        }
        
        var leftColumnHeight: CGFloat = 0
        for l in titlesLayers {
            l.frame.origin = CGPoint(x: insets.left + percentColumnWidth, y: leftColumnHeight + totalHeight)
            leftColumnHeight += l.frame.size.height + lineSpacing
        }
        
        var rightColumnHeight: CGFloat = 0
        for l in valuesLayers {
            l.frame.origin = CGPoint(x: totalWidth - rightColumnWidth - insets.right, y: rightColumnHeight + totalHeight)
            l.frame.size.width = rightColumnWidth
            rightColumnHeight += l.frame.size.height + lineSpacing
        }
        totalHeight = totalHeight + max(leftColumnHeight, rightColumnHeight, percentColumnHeight) + insets.bottom - lineSpacing
        let newSize = CGSize(width: totalWidth, height: totalHeight)
        var anim: CABasicAnimation? = nil
        if animated {
            anim = CABasicAnimation()
            anim?.duration = 0.1
            anim?.fromValue = plateLayer.frame.size
            anim?.toValue = newSize
            plateLayer.frame.size = newSize
            plateLayer.add(anim!, forKey: "frame.size")
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            plateLayer.frame.size = newSize
            CATransaction.commit()
        }
        
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
        
        plateLayer.fillColor = plateColor.cgColor
        if let titleLayer = titleLayer {
            titleLayer.foregroundColor = titleColor.cgColor
        }
        for l in titlesLayers {
            l.foregroundColor = textColor.cgColor
        }
    }
}
