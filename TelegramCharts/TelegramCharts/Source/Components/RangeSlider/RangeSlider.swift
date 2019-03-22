//
//  RangeSlider.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

protocol RangeSliderDelegate {
    func sliderLeftDidChange(sender: RangeSlider)
    func sliderRightDidChange(sender: RangeSlider)
    func sliderDidScroll(sender: RangeSlider)
}

class RangeSlider: UIControl {

    var delegate: RangeSliderDelegate?

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
    var lowerValue: CGFloat? {
        didSet {
            updateLayout()
        }
    }
    var upperValue: CGFloat? {
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

    private var minValueDelta: CGFloat = 0
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
        guard let lowerValue = lowerValue,
            let upperValue = upperValue else {
                return
        }

        let thumbLeft = lowerValue * thumbView.bounds.width
        let thumbRight = upperValue * thumbView.bounds.width
        thumbView.leftBorder = thumbLeft
        thumbView.rightBorder = thumbRight

        minValueDelta = 44.0 / thumbView.bounds.width
        
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
        guard let lowerValue = lowerValue,
            let upperValue = upperValue else {
                return false
        }
        
        let location = touch.location(in: thumbView)
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        previousLocation = location

        switch touchResult {
        case .none:
            break
        case .left:
            self.lowerValue = min(max(minimumValue, lowerValue + deltaValue), upperValue - minValueDelta)
            delegate?.sliderLeftDidChange(sender: self)
        case .right:
            self.upperValue = max(min(maximumValue, upperValue + deltaValue), lowerValue + minValueDelta)
            delegate?.sliderRightDidChange(sender: self)
        case .center:
            var newDelta: CGFloat = deltaValue
            if lowerValue + deltaValue < minimumValue {
                newDelta = minimumValue - lowerValue
            } else if upperValue + deltaValue > maximumValue {
                newDelta = maximumValue - upperValue
            }
            self.lowerValue! += newDelta
            self.upperValue! += newDelta
            delegate?.sliderDidScroll(sender: self)
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
