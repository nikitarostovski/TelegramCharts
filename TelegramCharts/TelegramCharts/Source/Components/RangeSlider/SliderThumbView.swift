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
            updateLayers()
        }
    }
    var rightBorder: CGFloat = 0 {
        didSet {
            updateLayers()
        }
    }

    private let thumbTouchWidth: CGFloat = 44.0

    private let thumbWidth: CGFloat = 16.0
    private let cornerRadius: CGFloat = 4.0
    private let borderThickness: CGFloat = 2.0

    private var thumbLayer = CAShapeLayer()

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
        layer.addSublayer(thumbLayer)
        isUserInteractionEnabled = false
        drawThumb()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    // MARK: - Draw

    private func updateLayers() {
        drawThumb()
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

        thumbLayer.fillColor = UIColor.red.withAlphaComponent(0.5).cgColor
        thumbLayer.fillRule = .evenOdd
        thumbLayer.path = path.cgPath
    }
}
