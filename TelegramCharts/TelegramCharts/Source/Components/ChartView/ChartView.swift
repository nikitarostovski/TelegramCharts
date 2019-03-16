//
//  ChartView.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartView: UIView {

    var charts: ChartsData? {
        didSet {
            charts?.xVisibleRange = visibleRange
            update(animated: true)
        }
    }
    var axis: AxisData? {
        didSet {
            axis?.visibleRange = visibleRange
            update(animated: true)
        }
    }
    
    private var lastVisibleRange: ClosedRange<CGFloat> = 0 ... 1
    var visibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            update(animated: true)
        }
    }
    
    var lineWidth: CGFloat = 4.0 {
        didSet {
            update(animated: true)
        }
    }

    private var animator = PointAnimator()
    
    private var titleColor: UIColor = .black

    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Private

    private func initialSetup() {
        layer.masksToBounds = true
        startReceivingThemeUpdates()
    }

    private func update(animated: Bool = true) {
        let updateHandler: PointAnimationUpdateHandler = { [weak self] (phaseX, phaseY) in
            guard let self = self else { return }
            
            let lastLow = self.lastVisibleRange.lowerBound
            let lastUp = self.lastVisibleRange.upperBound
            let low = self.visibleRange.lowerBound
            let up = self.visibleRange.upperBound
            
            let curLow = lastLow + (low - lastLow) * phaseX
            let curUp = lastUp + (up - lastUp) * phaseX
            let range = curLow ... curUp
            
            if let axis = self.axis {
                axis.textWidth = 80
                axis.maxVisiblePositions = Int(self.bounds.width / axis.textWidth)
                axis.visibleRange = range
                axis.updateAlpha(phase: phaseY)
            }
            self.charts?.xVisibleRange = range
            self.lastVisibleRange = range

            self.setNeedsDisplay()
        }

        if animated {
            animator.animate(durationX: 0.05,
                             durationY: 0.1,
                             easingX: .easeOutCubic,
                             easingY: .linear,
                             update: updateHandler,
                             finish: nil)
        } else {
            updateHandler(1.0, 1.0)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        ChartDrawer.configureContext(context: context, lineWidth: lineWidth)
        charts?.getLinesToDraw(viewport: bounds).forEach { (points, color) in
            ChartDrawer.drawChart(points: points, color: color.cgColor, context: context)
        }
        
        AxisDrawer.configureContext(context: context)
        axis?.getTextToDraw(viewport: bounds).forEach { [weak self] axisPoint in
            let attributedString = NSAttributedString(string: axisPoint.title, attributes: self?.textAttributes(alpha: axisPoint.currentAlpha))
            let height: CGFloat = 21
            let width = attributedString.width(withConstrainedHeight: height)
            let x = axisPoint.dispX - width / 2
            let y = bounds.height - height
            AxisDrawer.drawText(text: attributedString, frame: CGRect(x: x, y: y, width: width, height: height))
        }
    }
}

// MARK: - Stylable

extension ChartView: Stylable {

    func textAttributes(alpha: CGFloat) -> [NSAttributedString.Key: Any] {
        return [.foregroundColor: titleColor.withAlphaComponent(alpha)]
    }
    
    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
        titleColor = theme.chartTitlesColor
        setNeedsDisplay()
    }
}
