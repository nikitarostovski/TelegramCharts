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

    private let updateQueue = DispatchQueue(label: "ChartUpdateQueue",
                                            qos: .utility,
                                            attributes: [])

    private var xAnimator = Animator()
    private var yAnimator = Animator()
    private var fadeAnimator = Animator()
    private var chartBounds: CGRect = .zero
    private var titleColor: UIColor = .black
    private var gridMainColor: UIColor = .darkGray
    private var gridAuxColor: UIColor = .lightGray

    private var plate: PlateView!
    private var selectionXIndex: Int?
    private var selectionViewPosition: CGFloat = 0 {
        didSet {
            updatePlatePosition()
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
        updatePlatePosition()
        update()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Private

    private func initialSetup() {
        layer.masksToBounds = true
        startReceivingThemeUpdates()
        plate = PlateView(frame: .zero)
        plate.isHidden = true
        plate.alpha = 0
        addSubview(plate)
    }

    private func update() {
        updateQueue.async { [ weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.moveSelection()
            }
            var maxVisibleY: CGFloat = 0
            if let lines = self.lines {
                for line in lines {
                    line.normalizeX(range: self.xRange)
                    if !line.isHidden {
                        maxVisibleY = max(maxVisibleY, line.yMaxVisible ?? 0)
                    }
                }
                for line in lines {
                    line.normalizeY(range: 0 ... maxVisibleY)
                }
            }
            if let grid = self.grid {
                grid.normalizeX(range: self.xRange)
                grid.normalizeY(range: 0 ... maxVisibleY)
            }
            if let lines = self.lines {
                for line in lines {
                    line.updateX(phase: 1)
                }
            }
            if let grid = self.grid {
                grid.updateX(phase: 1)
            }
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            self.yAnimator.animate(duration: 0.15, update: { phase in
                if let lines = self.lines {
                    for line in lines {
                        line.updateY(phase: phase)
                    }
                }
                if let grid = self.grid {
                    grid.updateY(phase: phase)
                }
                self.setNeedsDisplay()
            })
            self.fadeAnimator.animate(duration: 0.15, update: { phase in
                if let lines = self.lines {
                    for line in lines {
                        line.updateAlpha(phase: phase)
                    }
                    self.setNeedsDisplay()
                }
            })
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        if let grid = grid {
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
            if let selectionXIndex = selectionXIndex, lines.count > 0 {
                ChartViewRenderer.configureContext(context: context, lineWidth: 0.5)
                let position = chartBounds.minX + lines.first!.normX[selectionXIndex] * chartBounds.width
                let ptA = CGPoint(x: position, y: 0)
                let ptB = CGPoint(x: position, y: chartBounds.maxY)
                ChartViewRenderer.drawLine(pointA: ptA,
                                           pointB: ptB,
                                           color: gridMainColor.cgColor,
                                           context: context)
            }
            ChartViewRenderer.configureContext(context: context, lineWidth: lineWidth)
            for line in lines {
                if line.isHidden && line.currentAlpha == 0 {
                    continue
                }
                let color = line.color.withAlphaComponent(line.currentAlpha).cgColor
                var points = [CGPoint]()
                for i in line.normX.indices {
                    guard line.normX[i] > -0.1 && line.normX[i] < 1.1 else {
                        continue
                    }
                    let xView = chartBounds.minX + line.normX[i] * chartBounds.width
                    let yView = chartBounds.maxY - (line.normY[i] * chartBounds.height)
                    points.append(CGPoint(x: xView, y: yView))
                }
                ChartViewRenderer.drawChart(points: points, color: color, context: context)
                if let selectionXIndex = selectionXIndex {
                    let fillColor = (backgroundColor ?? .clear).cgColor
                    ChartViewRenderer.configureContext(context: context, lineWidth: lineWidth, fillColor: fillColor)
                    let xView = chartBounds.minX + line.normX[selectionXIndex] * chartBounds.width
                    let yView = chartBounds.maxY - (line.normY[selectionXIndex] * chartBounds.height)
                    let radius: CGFloat = 3
                    ChartViewRenderer.drawSelectionCircle(point: CGPoint(x: xView, y: yView), color: color, radius: radius, context: context)
                }
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

    private func updatePlatePosition() {
        let inset: CGFloat = 8
        var x = chartBounds.minX + selectionViewPosition * chartBounds.width
        x = min(x, chartBounds.maxX - plate.frame.width / 2)
        x = max(x, chartBounds.minX + plate.frame.width / 2)
        var y = inset + plate.frame.height / 2
        var overlaps = false
        if let lines = lines, let selectionXIndex = selectionXIndex {
            var yPointsToAvoid = [inset, chartBounds.maxY - inset]
            lines.forEach { line in
                let yView = chartBounds.maxY - (line.normY[selectionXIndex] * chartBounds.height)
                yPointsToAvoid.append(yView)
                if yView >= y - plate.frame.height / 2 && yView <= y + plate.frame.height / 2 {
                    overlaps = true
                }
            }
            if overlaps {
                yPointsToAvoid.sort(by: <)
                for i in 1 ..< yPointsToAvoid.count {
                    let ptA = yPointsToAvoid[i - 1]
                    let ptB = yPointsToAvoid[i]
                    let center = ptA + (ptB - ptA) / 2
                    if center + plate.frame.height / 2 < ptB && center - plate.frame.height / 2 > ptA {
                        y = center
                        break
                    }
                }
            }
        }
        plate.center = CGPoint(x: x, y: y)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let pos = touches.first?.location(in: self),
            chartBounds.contains(pos),
            !(plate.frame.contains(pos) && !plate.isHidden)
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
        if plate.isHidden {
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
        guard plate.isHidden && plate.alpha == 0 else { return }
        plate.alpha = 0
        plate.isHidden = false
        moveSelection(animated: false)
        UIView.animate(withDuration: 0.15) {
            self.plate.alpha = 1.0
        }
        setNeedsDisplay()
    }

    private func moveSelection(animated: Bool = true) {
        guard !plate.isHidden else { return }
        guard let selectionXIndex = selectionXIndex,
            let newPos = lines?.first?.normX[selectionXIndex] else {
                hideSelection()
                return
        }
        if let data = getChartCurrentData() {
            plate.update(date: data.0, numbers: data.1)
        }
        let transitionClosure = {
            self.selectionViewPosition = newPos
        }
        if animated {
            UIView.animate(withDuration: 0.15) {
                transitionClosure()
            }
        } else {
            transitionClosure()
        }
        setNeedsDisplay()
    }

    func hideSelection() {
        guard !plate.isHidden && plate.alpha == 1 else { return }
        UIView.animate(withDuration: 0.15, animations: {
            self.plate.alpha = 0
        }) { _ in
            self.selectionXIndex = nil
            self.plate.isHidden = true
            self.setNeedsDisplay()
        }
    }

    private func getChartCurrentData() -> (Date, [(Int, UIColor)])? {
        guard let lines = lines,
            let selectionXIndex = selectionXIndex,
            let date = grid?.xAxisData[selectionXIndex] as? Date else {
            return nil
        }
        var numbers = [(Int, UIColor)]()
        for line in lines {
            let number = line.y[selectionXIndex]
            let color = line.color
            numbers.append((Int(number * 1000), color))
        }
        return (date, numbers)
    }
}
