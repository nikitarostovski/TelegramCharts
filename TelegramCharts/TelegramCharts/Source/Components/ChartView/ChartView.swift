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
    var visibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            charts?.xVisibleRange = visibleRange
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
        /*let updateHandler: PointAnimationUpdateHandler = { [weak self] (phaseX, phaseY) in
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
        }*/
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        charts?.getLinesToDraw(viewport: bounds).forEach { (points, color) in
            ChartDrawer.configureContext(context: context, lineWidth: lineWidth, color: color.cgColor)
            ChartDrawer.drawChart(points: points, context: context)
        }
        
        
        /*self.charts.lines.forEach { [weak self] line in
            guard let self = self else { return }
            ChartDrawer.configureContext(context: context, lineWidth: self.lineWidth, color: line.color.cgColor)
            let values = line.displayValues
            let points = values.map { CGPoint(x: $0.displayX, y: $0.displayY) }
            ChartDrawer.drawChart(points: points, context: context)
        }
        guard let values = charts.lines.first?.displayValues else { return }
        var titles = [(NSAttributedString, CGRect)]()
        values.forEach { value in
            var title = value.xTitle
            
            var attributes = title.attributes(at: 0, effectiveRange: nil)
            attributes[.foregroundColor] = titleColor
            title = NSAttributedString(string: title.string, attributes: attributes)
            
            let size = value.xTitleSize
            let rect = CGRect(x: value.displayX - size.width / 2,
                              y: bounds.height - size.height,
                              width: size.width,
                              height: size.height)
            
            titles.append((title, rect))
        }
        ChartDrawer.drawXTitles(titles: titles)*/
    }
}

// MARK: - Stylable

extension ChartView: Stylable {

    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
        titleColor = theme.chartTitlesColor
        setNeedsDisplay()
    }
}
