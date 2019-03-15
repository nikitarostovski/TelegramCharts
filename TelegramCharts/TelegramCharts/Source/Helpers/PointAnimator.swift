//
//  PointAnimator.swift
//  TelegramCharts
//
//  Created by Rost on 13/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias PointAnimationUpdateHandler = ((CGFloat, CGFloat) -> Void)
typealias PointAnimationFinishHandler = (() -> Void)

class PointAnimator {

    var updateHandler: PointAnimationUpdateHandler?
    var finishHandler: PointAnimationFinishHandler?

    var phaseX: CGFloat = 1
    var phaseY: CGFloat = 1
    
    private var displayLink: CADisplayLink?
    private var easingFunctionX: EasingFunction?
    private var easingFunctionY: EasingFunction?

    private var startTimeX: TimeInterval = 0
    private var finishTimeX: TimeInterval = 0
    private var startTimeY: TimeInterval = 0
    private var finishTimeY: TimeInterval = 0
    
    func animate(durationX: TimeInterval,
                 durationY: TimeInterval,
                 easingX: AnimationEasingType? = nil,
                 easingY: AnimationEasingType? = nil,
                 update: PointAnimationUpdateHandler?,
                 finish: PointAnimationFinishHandler? = nil) {

        finishAnimation()
        updateHandler = update
        finishHandler = finish
        easingFunctionX = easingFunction(type: easingX ?? .linear)
        easingFunctionY = easingFunction(type: easingY ?? .linear)
        startTimeX = CACurrentMediaTime()
        startTimeY = CACurrentMediaTime()
        finishTimeX = startTimeX + durationX
        finishTimeY = startTimeY + durationY
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFire))
        displayLink!.add(to: .main, forMode: .common)
    }
    
    func finishAnimation() {
        guard let displayLink = displayLink else { return }
        
        displayLink.remove(from: .main, forMode: .common)
        self.displayLink = nil

        finishHandler?()
    }
    
    @objc private func displayLinkFire() {
        let currentTime: TimeInterval = CACurrentMediaTime()
        updatePhases(currentTime: currentTime)
        updateHandler?(phaseX, phaseY)
        
        if currentTime >= max(finishTimeX, finishTimeY) {
            finishAnimation()
        }
    }
    
    private func updatePhases(currentTime: TimeInterval) {
        guard let easingX = easingFunctionX,
            let easingY = easingFunctionY else {
                return
        }
        if currentTime <= finishTimeX {
            let elapsedX: TimeInterval = min(currentTime - startTimeX, finishTimeX - startTimeX)
            phaseX = easingX(elapsedX, finishTimeX - startTimeX)
        }
        if currentTime <= finishTimeY {
            let elapsedY: TimeInterval = min(currentTime - startTimeY, finishTimeY - startTimeY)
            phaseY = easingY(elapsedY, finishTimeY - startTimeY)
        }
    }
}

// MARK: - Easing

typealias EasingFunction = (TimeInterval, TimeInterval) -> CGFloat

enum AnimationEasingType {
    case linear
    case easeOutCubic
}

extension PointAnimator {
    
    private func easingFunction(type: AnimationEasingType) -> EasingFunction {
        switch type {
        case .linear:
            return easingLinear
        case .easeOutCubic:
            return easingOutCubic
        }
    }
    
    private func easingLinear(elapsed: TimeInterval, duration: TimeInterval) -> CGFloat {
        return CGFloat(elapsed) / CGFloat(duration)
    }
    
    private func easingOutCubic(elapsed: TimeInterval, duration: TimeInterval) -> CGFloat {
        var position = CGFloat(elapsed) / CGFloat(duration)
        position -= 1.0
        return (position * position * position + 1.0)
    }
}
