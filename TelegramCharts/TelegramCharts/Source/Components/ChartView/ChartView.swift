//
//  ChartView.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartView: UIView {

    var charts = ChartsData() {
        didSet {
            charts.normalize(range: visibleRange)
            update(animated: true)
        }
    }
    var visibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            charts.normalize(range: visibleRange)
            update(animated: true)
        }
    }
    
    var lineWidth: CGFloat = 4.0 {
        didSet {
            update(animated: true)
        }
    }

    private var animator = PointAnimator()
    private var currentDisplayCharts = ChartsData()

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
            self.charts.updateCurrentXPoints(phase: phaseX)
            self.charts.updateCurrentYPoints(phase: phaseY)
            self.charts.calculateDisplayValues(viewport: self.bounds)

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
        self.charts.lines.forEach { [weak self] line in
            guard let self = self else { return }
            ChartDrawer.configureContext(context: context, lineWidth: self.lineWidth, color: line.color.cgColor)
            ChartDrawer.drawChart(points: line.displayPoints, context: context)
        }
    }
}

// MARK: - Stylable

extension ChartView: Stylable {

    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
    }
}
