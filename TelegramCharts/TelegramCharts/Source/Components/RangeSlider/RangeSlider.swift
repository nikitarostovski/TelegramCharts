//
//  RangeSlider.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class RangeSlider: UIControl {
    
    var minimumValue: CGFloat = 0 {
        didSet {
            updateLayout()
        }
    }
    var maximumValue: CGFloat = 1 {
        didSet {
            updateLayout()
        }
    }
    var lowerValue: CGFloat = 0.2 {
        didSet {
            updateLayout()
        }
    }
    var upperValue: CGFloat = 0.8 {
        didSet {
            updateLayout()
        }
    }
    var tintAreaInsets: UIEdgeInsets = .zero {
        didSet {
            updateLayout()
        }
    }

    private var thumbView: SliderThumbView!
    private var tintLayer = CAShapeLayer()
    private var unselectedTintColor: UIColor = UIColor.black.withAlphaComponent(0.9)

    private var previousLocation = CGPoint()
    private var touchResult = SliderThumbHitTestResult.none

    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }

    // MARK: - Setup

    private func initialSetup() {
        backgroundColor = .clear

        thumbView = SliderThumbView(frame: .zero)
        addSubview(thumbView)

        tintLayer.masksToBounds = true
        layer.addSublayer(tintLayer)
        
        startReceivingThemeUpdates()
    }

    // MARK: - Layout
    
    private func updateLayout() {
        thumbView.frame = bounds

        let thumbLeft = lowerValue * thumbView.bounds.width
        let thumbRight = upperValue * thumbView.bounds.width
        thumbView.leftBorder = thumbLeft
        thumbView.rightBorder = thumbRight

        tintLayer.frame = bounds.inset(by: tintAreaInsets)
        drawTint()
    }

    private func drawTint() {
        let hollowRect = CGRect(x: thumbView.leftBorder,
                                y: 0,
                                width: thumbView.rightBorder - thumbView.leftBorder,
                                height: bounds.height)
        
        let path = UIBezierPath(rect: bounds)
        let hollowPath = UIBezierPath(rect: hollowRect)
        path.append(hollowPath)
        path.usesEvenOddFillRule = true

        tintLayer.fillColor = unselectedTintColor.cgColor
        tintLayer.fillRule = .evenOdd
        tintLayer.path = path.cgPath
    }
}

// MARK: - Touches

extension RangeSlider {

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: thumbView)
        touchResult = thumbView.hitTest(point: previousLocation)
        return touchResult != .none
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: thumbView)
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        previousLocation = location

        if touchResult == .left || touchResult == .center {
            lowerValue += deltaValue
        }
        if touchResult == .right || touchResult == .center {
            upperValue += deltaValue
        }
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        touchResult = .none
    }
}

// MARK: - Themes

extension RangeSlider: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        unselectedTintColor = theme.sliderTintColor
        drawTint()
    }
}
