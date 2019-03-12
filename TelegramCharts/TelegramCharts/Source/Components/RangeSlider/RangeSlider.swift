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

    private var thumbView: SliderThumbView!

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

    // MARK: - Setup

    private func initialSetup() {
        backgroundColor = UIColor.cyan.withAlphaComponent(0.5)

        thumbView = SliderThumbView(frame: .zero)
        addSubview(thumbView)
    }

    // MARK: - Layout
    
    private func updateLayout() {
        let thumbX = lowerValue * bounds.width
        let thumbWidth = (upperValue - lowerValue) * bounds.width
        thumbView.frame = CGRect(x: thumbX, y: 0, width: thumbWidth, height: bounds.height)
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
