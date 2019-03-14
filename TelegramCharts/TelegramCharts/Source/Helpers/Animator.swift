//
//  Animator.swift
//  TelegramCharts
//
//  Created by Rost on 13/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias AnimationUpdateHandler = ((CGFloat) -> Void)
typealias AnimationFinishHandler = (() -> Void)

class Animator {

    var updateHandler: AnimationUpdateHandler?
    var finishHandler: AnimationFinishHandler?
    
    var phase: CGFloat = 1
    
    private var displayLink: CADisplayLink?
    private var easingFunction: EasingFunction?
    
    private var startTime: TimeInterval = 0
    private var finishTime: TimeInterval = 0
    
    func animate(duration: TimeInterval,
                 easing: AnimationEasingType? = nil,
                 update: AnimationUpdateHandler?,
                 finish: AnimationFinishHandler?) {

        updateHandler = update
        finishHandler = finish
        easingFunction = easingFunction(type: easing ?? .linear)
        startTime = CACurrentMediaTime()
        finishTime = startTime + duration
        finishAnimation()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFire))
        displayLink!.add(to: .main, forMode: .common)
    }
    
    func finishAnimation() {
        guard let displayLink = displayLink else { return }
        
        displayLink.remove(from: .main, forMode: .common)
        self.displayLink = nil

//        if phase != 1 {
//            phase = 1
//            updateHandler?(phase)
//        }
        finishHandler?()
    }
    
    @objc private func displayLinkFire() {
        let currentTime: TimeInterval = CACurrentMediaTime()
        updatePhase(currentTime: currentTime)
        updateHandler?(phase)
        
        if currentTime >= finishTime {
            finishAnimation()
        }
    }
    
    private func updatePhase(currentTime: TimeInterval) {
        guard let easingFunction = easingFunction else { return }
        let duration = finishTime - startTime
        let elapsed: TimeInterval = min(currentTime - startTime, finishTime - startTime)
        phase = easingFunction(elapsed, duration)
    }
}

// MARK: - Easing

typealias EasingFunction = (TimeInterval, TimeInterval) -> CGFloat

enum AnimationEasingType {
    case linear
    case easeOutCubic
}

extension Animator {
    
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
