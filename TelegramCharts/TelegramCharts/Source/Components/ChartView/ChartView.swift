//
//  ChartView.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ChartLine = (values: [Int], color: UIColor, name: String)

class ChartView: UIView {

    var xRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            recalc()
        }
    }
    var lineWidth: CGFloat = 4.0 {
        didSet {
            redraw()
        }
    }
    var chartInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    var gridVisible = true
    
    private var yDrawAxis: ChartYDrawAxis?
    private var xDrawAxis: ChartXDrawAxis?
    private var drawLines: [ChartDrawLine]?
    private var maxValue: Int = 0
    private var maxVisibleValue: Int? {
        didSet {
            targetMaxVisibleY = CGFloat(maxVisibleValue ?? 0)
            yAnimator.animate(duration: 2.0, easing: .linear, update: { [weak self] phase in
                guard let self = self else { return }
                self.maxVisibleY = self.maxVisibleY + (self.targetMaxVisibleY - self.maxVisibleY) * phase
                if let yDrawAxis = self.yDrawAxis, self.gridVisible {
                    for pt in yDrawAxis.hidingPoints {
                        pt.alpha = pt.alpha - pt.alpha * phase * 2
                    }
                    for pt in yDrawAxis.points {
                        pt.alpha = pt.alpha + (1 - pt.alpha) * phase
                    }
                }
                self.redraw()
            }, finish: nil)
        }
    }
    private var maxVisibleY: CGFloat = 0
    private var targetMaxVisibleY: CGFloat = 0
    private var xAnimator = Animator()
    private var yAnimator = Animator()
    private var chartBounds: CGRect = .zero
    private var titleColor: UIColor = .black
    private var gridMainColor: UIColor = .darkGray
    private var gridAuxColor: UIColor = .lightGray

    private let updateQueue = DispatchQueue(label: "ChartUpdateQueue",
                                            qos: .userInitiated,
                                            attributes: [])
    
    private var plate: PlateView!
    private var selectionXIndex: Int?
    private var selectionViewPosition: CGFloat = 0 {
        didSet {
//            updatePlatePosition()
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
//        updatePlatePosition()
        recalc()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Public
    
    func setupData(lines: [ChartLine], dates: [Date]) {
        var newDrawLines = [ChartDrawLine]()
        for line in lines {
            newDrawLines.append(ChartDrawLine(color: line.color, points: line.values))
            self.maxValue = max(self.maxValue, line.values.max() ?? 0)
        }
        self.drawLines = newDrawLines
        self.yDrawAxis = ChartYDrawAxis(maxValue: self.maxValue)
        self.xDrawAxis = ChartXDrawAxis(dates: dates)
    }
    
    // MARK: - Private

    private func initialSetup() {
        backgroundColor = .clear
        layer.masksToBounds = true
        startReceivingThemeUpdates()
        plate = PlateView(frame: .zero)
        plate.isHidden = true
        plate.alpha = 0
        addSubview(plate)
    }

    private func recalc() {
        updateQueue.async { [ weak self] in
            guard let self = self else { return }
            guard let drawLines = self.drawLines else { return }
            DispatchQueue.main.async {
//                self.moveSelection()
            }
            var maxValue: Int = 0
            for i in drawLines.indices {
                let drawLine = drawLines[i]

                drawLine.firstIndex = max(Int(self.xRange.lowerBound * CGFloat(drawLine.points.count) - 0.5), 0)
                drawLine.lastIndex = min(Int(self.xRange.upperBound * CGFloat(drawLine.points.count) + 0.5), drawLine.points.count - 1)

                for j in drawLine.firstIndex ... drawLine.lastIndex {
                    let xNorm = (drawLine.points[j].originalX - self.xRange.lowerBound) / (self.xRange.upperBound - self.xRange.lowerBound)
                    drawLine.points[j].x = self.chartBounds.minX + xNorm * self.chartBounds.width
                    if xNorm >= 0 && xNorm <= 1 {
                        maxValue = max(maxValue, drawLine.points[j].value)
                    }
                }
            }
            if self.maxVisibleValue != maxValue {
                self.maxVisibleValue = maxValue
                self.yDrawAxis?.maxValue = maxValue
            }
            self.redraw()
        }
    }

    private func redraw(animated: Bool = true) {
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        
        if let yDrawAxis = yDrawAxis, gridVisible {
            context.setLineWidth(0.5)
            let allPoints = yDrawAxis.points + yDrawAxis.hidingPoints
            for p in allPoints {
                if p.value == 0 {
                    context.setStrokeColor(gridMainColor.cgColor)
                } else {
                    context.setStrokeColor(gridAuxColor.cgColor)
                }
                let normY = maxVisibleY == 0 ? 0 : CGFloat(p.value) / maxVisibleY
                let y = chartBounds.maxY - normY * chartBounds.height
                let height: CGFloat = 18
                let frame = CGRect(x: chartBounds.minX,
                                   y: y - height,
                                   width: chartBounds.width, height: height)
                let attrStr = NSAttributedString(string: p.title,
                                                 attributes: yAxisTextAttributes(alpha: p.alpha))
                attrStr.draw(in: frame)
                
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: chartBounds.maxX, y: y))
                context.strokePath()
            }
        }

        context.setLineWidth(lineWidth)
        for line in drawLines ?? [] {
            context.setStrokeColor(line.color.cgColor)
            for i in line.firstIndex ... line.lastIndex {
                let normY = maxVisibleY == 0 ? 0 : CGFloat(line.points[i].value) / maxVisibleY
                let pt = CGPoint(x: line.points[i].x, y: self.chartBounds.maxY - normY * self.chartBounds.height)
                if i == line.firstIndex {
                    context.move(to: pt)
                    continue
                } else {
                    context.addLine(to: pt)
                }
            }
            context.strokePath()

            /*let radius: CGFloat = 4
            for i in 0 ..< line.points.count {
                guard line.points[i].isSelected else { continue }
                let rect = CGRect(x: line.points[i].point.x - radius, y: line.points[i].point.y - radius, width: 2 * radius, height: 2 * radius)
                context.addEllipse(in: rect)
                context.drawPath(using: .fillStroke)
            }*/
            
            /*if let selectionXIndex = selectionXIndex {
             let fillColor = (backgroundColor ?? .clear).cgColor
             ChartViewRenderer.configureContext(context: context, lineWidth: lineWidth, fillColor: fillColor)
             let xView = chartBounds.minX + line.normX[selectionXIndex] * chartBounds.width
             let yView = chartBounds.maxY - (line.normY[selectionXIndex] * chartBounds.height)
             let radius: CGFloat = 3
             ChartViewRenderer.drawSelectionCircle(point: CGPoint(x: xView, y: yView), color: color, radius: radius, context: context)
             }*/
        }
    }
}

// MARK: - Stylable

extension ChartView: Stylable {

    private func yAxisTextAttributes(alpha: CGFloat) -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [
            .foregroundColor: titleColor.withAlphaComponent(alpha),
            .paragraphStyle: style
        ]
    }
    
    private func xAxisTextAttributes(alpha: CGFloat) -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [
            .foregroundColor: titleColor.withAlphaComponent(alpha),
            .paragraphStyle: style
        ]
    }
    
    func themeDidUpdate(theme: Theme) {
        titleColor = theme.chartTitlesColor
        gridMainColor = theme.chartGridMainColor
        gridAuxColor = theme.chartGridAuxColor
        redraw()
    }
}

// MARK: - Selection View

extension ChartView {

    /*private func updatePlatePosition() {
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
        redraw()
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
        redraw()
    }

    func hideSelection() {
        guard !plate.isHidden && plate.alpha == 1 else { return }
        UIView.animate(withDuration: 0.15, animations: {
            self.plate.alpha = 0
        }) { _ in
            self.selectionXIndex = nil
            self.plate.isHidden = true
            self.redraw()
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
    }*/
}
