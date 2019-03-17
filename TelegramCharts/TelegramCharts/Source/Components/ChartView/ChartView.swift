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
    var grid: GridData? {
        didSet {
            grid?.maxVisibleValue = 100
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
    var chartInsets = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0) {
        didSet {
            chartBounds = self.bounds.inset(by: chartInsets)
            update()
        }
    }
    
    private var animator = PointAnimator()
    private var chartBounds: CGRect = .zero
    private var titleColor: UIColor = .black
    private var gridMainColor: UIColor = .darkGray
    private var gridAuxColor: UIColor = .lightGray
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartBounds = self.bounds.inset(by: chartInsets)
        update()
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
            if let grid = self.grid {
                grid.maxVisibleValue = 100
                grid.updateAlpha(phase: phaseY)
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
        if let axis = self.axis {
            GridDrawer.configureContext(context: context, lineWidth: 0.5)
            let leftPoint = CGPoint(x: 0, y: chartBounds.maxY)
            let rightPoint = CGPoint(x: bounds.width, y: chartBounds.maxY)
            GridDrawer.drawLine(pointA: leftPoint,
                                pointB: rightPoint,
                                color: gridMainColor.cgColor,
                                context: context)
            AxisDrawer.configureContext(context: context)
            axis.getTextToDraw(viewport: bounds).forEach { [weak self] axisPoint in
                let attributedString = NSAttributedString(string: axisPoint.title, attributes: self?.xAxisTextAttributes(alpha: axisPoint.currentAlpha))
                let height: CGFloat = 20
                let width = attributedString.width(withConstrainedHeight: height)
                let x = axisPoint.dispX - width / 2
                let y = bounds.height - chartInsets.bottom + (chartInsets.bottom - height) / 2
                AxisDrawer.drawText(text: attributedString, frame: CGRect(x: x, y: y, width: width, height: height))
            }
        }
        if let grid = self.grid {
            grid.getLinesToDraw(viewport: chartBounds).forEach {
                let ptA = CGPoint(x: chartBounds.minX, y: $0.dispY)
                let ptB = CGPoint(x: chartBounds.maxX, y: $0.dispY)
                let textWidth = chartBounds.width
                let text = NSAttributedString(string: String($0.value), attributes: yAxisTextAttributes(alpha: $0.currentAlpha))
                let textHeight = text.height(withConstrainedWidth: textWidth)
                let textFrame = CGRect(x: chartBounds.minX,
                                       y: $0.dispY - textHeight,
                                       width: textWidth,
                                       height: textHeight)
                GridDrawer.drawText(text: text, frame: textFrame)
                let color = gridAuxColor.withAlphaComponent($0.currentAlpha)
                GridDrawer.drawLine(pointA: ptA, pointB: ptB, color: color.cgColor, context: context)
            }
        }
        ChartDrawer.configureContext(context: context, lineWidth: lineWidth)
        charts?.getLinesToDraw(viewport: chartBounds).forEach { (points, color) in
            ChartDrawer.drawChart(points: points, color: color.cgColor, context: context)
        }
    }
}

// MARK: - Stylable

extension ChartView: Stylable {

    func yAxisTextAttributes(alpha: CGFloat) -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [
            .foregroundColor: titleColor.withAlphaComponent(alpha),
            .paragraphStyle: style
        ]
    }
    
    func xAxisTextAttributes(alpha: CGFloat) -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [
            .foregroundColor: titleColor.withAlphaComponent(alpha),
            .paragraphStyle: style
        ]
    }
    
    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
        titleColor = theme.chartTitlesColor
        gridMainColor = theme.chartGridMainColor
        gridAuxColor = theme.chartGridAuxColor
        setNeedsDisplay()
    }
}
