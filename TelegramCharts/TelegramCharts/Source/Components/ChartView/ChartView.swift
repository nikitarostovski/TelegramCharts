//
//  ChartView.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartView: UIView {

    var lines: [ChartLine]?
    var grid: ChartGrid?

    var xRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            update()
        }
    }
    var lineWidth: CGFloat = 4.0 {
        didSet {
            update()
        }
    }
    var chartInsets = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0)

    private var animator = Animator()
    private var chartBounds: CGRect = .zero
    private var titleColor: UIColor = .black
    private var gridMainColor: UIColor = .darkGray
    private var gridAuxColor: UIColor = .lightGray
    
    private var selectionView = SelectionView(frame: .zero)
    private var selectionXIndex: Int?
    private var selectionViewPosition: CGFloat = 0 {
        didSet {
            selectionView.updatePosition(pos: selectionViewPosition)
        }
    }
    
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
        selectionView.frame = chartBounds
        update()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Private

    private func initialSetup() {
        layer.masksToBounds = true
        startReceivingThemeUpdates()
        
        selectionView.isHidden = true
        selectionView.alpha = 0
        selectionView.isUserInteractionEnabled = false
        addSubview(selectionView)
    }

    private func update() {
        var maxVisibleY: CGFloat = 0
        if let lines = lines {
            for line in lines {
                line.normalizeX(range: xRange)
                maxVisibleY = max(maxVisibleY, line.yMaxVisible ?? 0)
            }
            for line in lines {
                line.normalizeY(range: 0 ... maxVisibleY)
            }
        }
        if let grid = grid {
            grid.normalizeX(range: xRange)
            grid.normalizeY(range: 0 ... maxVisibleY)
        }
        animator.animate(duration: 0.05, easing: .easeOutCubic, update: { [weak self] (phase) in
            guard let self = self else { return }
            if let lines = self.lines {
                for line in lines {
                    line.updateX(phase: phase)
                    line.updateY(phase: phase)
                }
            }
            if let grid = self.grid {
                self.moveSelection()
                grid.updateX(phase: phase)
                grid.updateY(phase: phase)
            }
            self.setNeedsDisplay()
        })
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if let grid = grid, false {
            ChartViewRenderer.configureContext(context: context, lineWidth: 0.5)
            let leftPoint = CGPoint(x: 0, y: chartBounds.maxY)
            let rightPoint = CGPoint(x: bounds.width, y: chartBounds.maxY)
            ChartViewRenderer.drawLine(pointA: leftPoint,
                                       pointB: rightPoint,
                                       color: gridMainColor.cgColor,
                                       context: context)
            for yPoint in grid.yPoints {
                let yView = chartBounds.maxY - (yPoint.normPos * chartBounds.height)

                let ptA = CGPoint(x: chartBounds.minX, y: yView)
                let ptB = CGPoint(x: chartBounds.maxX, y: yView)
                let color = self.gridAuxColor.withAlphaComponent(yPoint.currentAlpha)
                ChartViewRenderer.drawLine(pointA: ptA, pointB: ptB, color: color.cgColor, context: context)

                let text = NSAttributedString(string: yPoint.title, attributes: yAxisTextAttributes(alpha: yPoint.currentAlpha))
                let textWidth = chartBounds.width
                let textHeight = text.height(withConstrainedWidth: textWidth)
                let textFrame = CGRect(x: chartBounds.minX,
                                       y: yView - textHeight,
                                       width: textWidth,
                                       height: textHeight)
                ChartViewRenderer.drawText(text: text, frame: textFrame)
            }
            for xPoint in grid.xPoints {
                let xView = chartBounds.minX + xPoint.normPos * chartBounds.width
                let attributedString = NSAttributedString(string: xPoint.title, attributes: xAxisTextAttributes(alpha: xPoint.currentAlpha))
                let height: CGFloat = 20
                let width = attributedString.width(withConstrainedHeight: height)
                let x = xView - width / 2
                let y = bounds.height - chartInsets.bottom + (chartInsets.bottom - height) / 2
                ChartViewRenderer.drawText(text: attributedString, frame: CGRect(x: x, y: y, width: width, height: height))
            }
        }
        if let lines = lines {
            ChartViewRenderer.configureContext(context: context, lineWidth: lineWidth)
            for line in lines {
                let color = line.color.cgColor
                var points = [CGPoint]()
                for i in line.normX.indices {
                    let xView = chartBounds.minX + line.normX[i] * chartBounds.width
                    let yView = chartBounds.maxY - (line.normY[i] * chartBounds.height)
                    points.append(CGPoint(x: xView, y: yView))
                }
                ChartViewRenderer.drawChart(points: points, color: color, context: context)
            }
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

// MARK: - Selection View

extension ChartView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let pos = touches.first?.location(in: self),
            chartBounds.contains(pos),
            !(selectionView.plate.frame.contains(pos) && !selectionView.isHidden)
        else {
            hideSelection()
            return
        }
        let chartViewPos = (pos.x - chartBounds.minX) / chartBounds.width
        let normPos = chartViewPos * (xRange.upperBound - xRange.lowerBound) + xRange.lowerBound
        guard let closestIndex = grid?.getClosedXAxisIndex(position: normPos) else {
            return
        }
        selectionXIndex = closestIndex
        if selectionView.isHidden {
            showSelection()
        } else {
            moveSelection()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let pos = touches.first?.location(in: self),
            chartBounds.contains(pos) else {
            hideSelection()
            return
        }
        let chartViewPos = (pos.x - chartBounds.minX) / chartBounds.width
        let normPos = chartViewPos * (xRange.upperBound - xRange.lowerBound) + xRange.lowerBound
        guard let closestIndex = grid?.getClosedXAxisIndex(position: normPos) else {
            hideSelection()
            return
        }
        selectionXIndex = closestIndex
        moveSelection()
    }

    private func showSelection() {
        guard selectionView.isHidden && selectionView.alpha == 0 else { return }
        if let data = getChartCurrentData() {
            selectionView.updateData(date: data.0, numbers: data.1)
        }
        selectionView.alpha = 0
        selectionView.isHidden = false
        moveSelection(animated: false)
        UIView.animate(withDuration: 0.15) {
            self.selectionView.alpha = 1.0
        }
    }

    private func moveSelection(animated: Bool = true) {
        guard !selectionView.isHidden else { return }
        guard let selectionXIndex = selectionXIndex,
            let newPos = grid?.xPoints[selectionXIndex].newNormPos else {
                hideSelection()
                return
        }
        if let data = getChartCurrentData() {
            selectionView.updateData(date: data.0, numbers: data.1)
        }
        let transitionClosure = {
            self.selectionViewPosition = newPos * self.chartBounds.width
        }
        if animated {
            UIView.animate(withDuration: 0.15) {
                transitionClosure()
            }
        } else {
            transitionClosure()
        }
    }

    func hideSelection() {
        guard !selectionView.isHidden && selectionView.alpha == 1 else { return }
        UIView.animate(withDuration: 0.15, animations: {
            self.selectionView.alpha = 0
        }) { _ in
            self.selectionView.isHidden = true
        }
    }

    private func getChartCurrentData() -> (Date, [(Int64, UIColor)])? {
        guard let lines = lines,
            let selectionXIndex = selectionXIndex,
            let date = grid?.xAxisData[selectionXIndex] as? Date else {
            return nil
        }
        var numbers = [(Int64, UIColor)]()
        for line in lines {
            let number = line.y[selectionXIndex]
            let color = line.color
            numbers.append((Int64(number * 1000), color))
        }
        return (date, numbers)
    }
}
