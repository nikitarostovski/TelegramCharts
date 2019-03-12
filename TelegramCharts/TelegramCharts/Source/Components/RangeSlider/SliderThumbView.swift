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

    private let thumbWidth: CGFloat = 20.0
    private let cornerRadius: CGFloat = 5.0

    var isHighlighted = false {
        didSet {
            if isHighlighted {
                backgroundColor = .orange
            } else {
                backgroundColor = .red
            }
        }
    }

    private var thumbLayer = CAShapeLayer()

    // MARK: - Hit test

    func hitTest(point: CGPoint) -> SliderThumbHitTestResult {
        guard bounds.contains(point) else {
            return .none
        }
        let leftX = thumbWidth
        let rightX = bounds.width - thumbWidth

        let leftRect = CGRect(x: leftX, y: 0, width: thumbWidth, height: bounds.height)
        let rightRect = CGRect(x: rightX, y: 0, width: thumbWidth, height: bounds.height)

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
        layer.addSublayer(thumbLayer)
        isUserInteractionEnabled = false
        isHighlighted = false
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
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: cornerRadii)

        thumbLayer.fillColor = UIColor.red.withAlphaComponent(0.5).cgColor
        thumbLayer.fillRule = .evenOdd
        thumbLayer.path = path.cgPath
    }
}
