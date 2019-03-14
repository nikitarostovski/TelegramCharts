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
            update()
        }
    }
    var visibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            charts.normalize(range: visibleRange)
            update()
        }
    }
    
    var lineWidth: CGFloat = 4.0 {
        didSet {
            update()
        }
    }

    private var animator = Animator()
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

    func update() {
        animator.finishAnimation()
        animator.animate(duration: 0.1, easing: .linear, update: { [weak self] phase in
            guard let self = self else { return }

            self.charts.updateCurrentPoints(phase: phase)
            self.charts.calculateDisplayValues(viewport: self.frame)

            self.setNeedsDisplay()

            }, finish: nil)
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
