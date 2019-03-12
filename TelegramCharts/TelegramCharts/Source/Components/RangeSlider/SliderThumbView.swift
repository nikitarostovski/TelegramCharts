//
//  SliderThumbView.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 12/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

enum SliderThumbHitTestResult {
    case none
    case left
    case right
    case center
}

class SliderThumbView: UIView {

    var leftBorder: CGFloat = 0 {
        didSet {
            redrawLayers()
        }
    }
    var rightBorder: CGFloat = 0 {
        didSet {
            redrawLayers()
        }
    }

    private let thumbTouchWidth: CGFloat = 44.0

    private let thumbWidth: CGFloat = 11.0
    private let cornerRadius: CGFloat = 4.0
    private let borderThickness: CGFloat = 1.0
    private let arrowWidth: CGFloat = 4.0
    private let arrowHeight: CGFloat = 11.0
    private let arrowThickness: CGFloat = 5.0

    private var thumbLayer = CAShapeLayer()
    private var arrowsLayer = CAShapeLayer()
    private var fillColor: UIColor = UIColor.lightGray
    private var arrowColor: UIColor = UIColor.white

    // MARK: - Hit test

    func hitTest(point: CGPoint) -> SliderThumbHitTestResult {
        guard bounds.contains(point) else {
            return .none
        }
        let leftX = leftBorder - thumbTouchWidth / 2
        let rightX = rightBorder - thumbTouchWidth / 2

        let leftRect = CGRect(x: leftX, y: 0, width: thumbTouchWidth, height: bounds.height)
        let rightRect = CGRect(x: rightX, y: 0, width: thumbTouchWidth, height: bounds.height)

        if rightRect.contains(point) {
            return .right
        } else if leftRect.contains(point) {
            return .left
        } else {
            return .center
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    private func initialSetup() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        layer.addSublayer(thumbLayer)
        layer.addSublayer(arrowsLayer)
        startReceivingThemeUpdates()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        redrawLayers()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }

    // MARK: - Draw

    private func redrawLayers() {
        drawThumb()
        drawArrows()
    }

    private func drawThumb() {
        let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
        let rect = CGRect(x: leftBorder, y: 0, width: rightBorder - leftBorder, height: bounds.height)
        let hollowRect = CGRect(x: rect.origin.x + thumbWidth,
                                y: rect.origin.y + borderThickness,
                                width: rect.size.width - 2 * thumbWidth,
                                height: rect.size.height - 2 * borderThickness)

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: cornerRadii)
        let hollowPath = UIBezierPath(rect: hollowRect)
        path.append(hollowPath)
        path.usesEvenOddFillRule = true

        thumbLayer.fillColor = fillColor.cgColor
        thumbLayer.fillRule = .evenOdd
        thumbLayer.path = path.cgPath
    }
    
    private func drawArrows() {
        let arrowTop = (bounds.height - arrowHeight) / 2
        let arrowBottom = (bounds.height + arrowHeight) / 2
        let arrowCenterY = arrowTop + (arrowBottom - arrowTop) / 2
        
        let leftArrowLeft = leftBorder + (thumbWidth - arrowWidth) / 2
        let leftArrowRight = leftBorder + thumbWidth - (thumbWidth - arrowWidth) / 2
        
        let rightArrowLeft = rightBorder - thumbWidth + (thumbWidth - arrowWidth) / 2
        let rightArrowRight = rightBorder - (thumbWidth - arrowWidth) / 2
        
        let arrowsPath = UIBezierPath()
        arrowsPath.move(to: CGPoint(x: leftArrowRight, y: arrowTop))
        arrowsPath.addLine(to: CGPoint(x: leftArrowLeft, y: arrowCenterY))
        arrowsPath.addLine(to: CGPoint(x: leftArrowRight, y: arrowBottom))
        
        arrowsPath.move(to: CGPoint(x: rightArrowLeft, y: arrowTop))
        arrowsPath.addLine(to: CGPoint(x: rightArrowRight, y: arrowCenterY))
        arrowsPath.addLine(to: CGPoint(x: rightArrowLeft, y: arrowBottom))
        
        arrowsLayer.strokeColor = arrowColor.cgColor
        arrowsLayer.fillColor = UIColor.clear.cgColor
        arrowsLayer.lineJoin = .round
        arrowsLayer.lineCap = .round
        arrowsLayer.path = arrowsPath.cgPath
    }
}

// MARK: - Themes

extension SliderThumbView: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        fillColor = theme.sliderThumbColor
        arrowColor = theme.sliderThumbArrowColor
        redrawLayers()
    }
}
