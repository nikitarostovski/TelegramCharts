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

    var xRange: ClosedRange<CGFloat> = 0 ... 1
    var lineWidth: CGFloat = 4.0 {
        didSet {
            redraw()
        }
    }
    var xAxisTextSpacing: CGFloat = 20
    var yAxisGridStep: CGFloat = 0.18
    var chartInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    var gridVisible = true
    
    private var yDrawAxis: ChartDrawAxisY?
    private var xDrawAxis: ChartDrawAxisX?
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
    private var dateTextWidth: CGFloat = 60
    private var maxVisibleY: CGFloat = 0
    private var targetMaxVisibleY: CGFloat = 0
    private var fadeAnimator = Animator()
    private var xAnimator = Animator()
    private var yAnimator = Animator()
    private var chartBounds: CGRect = .zero
    private var titleColor: UIColor = .black
    private var gridMainColor: UIColor = .darkGray
    private var gridAuxColor: UIColor = .lightGray
    private var backColor: UIColor = .white

    private let updateQueue = DispatchQueue(label: "ChartUpdateQueue",
                                            qos: .userInitiated,
                                            attributes: [])
    
    private var plate: PlateView!
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
        updateXAxisTextWidth()
        updateYAxisDrawPositions()
        updatePlatePosition()
        recalc()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    // MARK: - Public
    
    func changeLowerBound(newLow: CGFloat) {
        xRange = newLow ... xRange.upperBound
        xDrawAxis?.changeLowerBound(newLow: newLow)
        update()
    }
    
    func changeUpperBound(newUp: CGFloat) {
        xRange = xRange.lowerBound ... newUp
        xDrawAxis?.changeUpperBound(newUp: newUp)
        update()
    }
    
    func changePoisition(newLow: CGFloat) {
        let diff = xRange.upperBound - xRange.lowerBound
        xRange = newLow ... newLow + diff
        xDrawAxis?.changePoisition(newLow: newLow)
        hideSelection()
        update()
    }
    
    func update() {
        animateXTitles()
        recalc()
        moveSelection()
    }

    func setLinesVisibility(visibility: [Bool]) {
        guard let drawLines = drawLines,
            visibility.count == drawLines.count
        else {
            return
        }
        for i in 0 ..< visibility.count {
            let drawLine = drawLines[i]
            let visible = visibility[i]
            if drawLine.isHiding == visible {
                drawLine.isHiding = !visible
            }
        }
        recalc()
        if !plate.isHidden, let data = getChartCurrentData() {
            plate.update(date: data.0, numbers: data.1)
        }
        fadeAnimator.animate(duration: 1, update: { [weak self] phase in
            guard let self = self else { return }
            guard let drawLines = self.drawLines else { return }
            for drawLine in drawLines {
                drawLine.alpha = drawLine.alpha + (drawLine.targetAlpha - drawLine.alpha) * phase
            }
            self.redraw()
        })
    }
    
    func setupData(lines: [ChartLine], dates: [Date]) {
        guard self.drawLines == nil else { return }
        var newDrawLines = [ChartDrawLine]()
        for line in lines {
            newDrawLines.append(ChartDrawLine(color: line.color, points: line.values))
            self.maxValue = max(self.maxValue, line.values.max() ?? 0)
        }
        dateTextWidth = 0
        for date in dates {
            let attributes = xAxisTextAttributes(alpha: 1)
            let stringDate = date.monthDayShortString()
            let attrDate = NSAttributedString(string: stringDate, attributes: attributes)
            let width = attrDate.width(withConstrainedHeight: .greatestFiniteMagnitude)
            dateTextWidth = max(dateTextWidth, width)
        }
        dateTextWidth += xAxisTextSpacing
        self.drawLines = newDrawLines
        self.yDrawAxis = ChartDrawAxisY(maxValue: self.maxValue)
        self.xDrawAxis = ChartDrawAxisX(dates: dates)
    }
    
    // MARK: - Private
    
    private func animateXTitles() {
        xAnimator.animate(duration: 0.15, update: { [weak self] phase in
            guard let self = self, let xDrawAxis = self.xDrawAxis else { return }
            for i in xDrawAxis.firstIndex ... xDrawAxis.lastIndex {
                let pt = xDrawAxis.points[i]
                pt.alpha = pt.alpha + (pt.targetAlpha - pt.alpha) * phase
            }
            self.redraw()
        })
    }
    
    private func updateYAxisDrawPositions() {
        if !gridVisible { return }
        var yPositions = [CGFloat]()
        var pos: CGFloat = 0
        while pos < 1.0 {
            yPositions.append(pos)
            pos += yAxisGridStep
        }
        yDrawAxis?.linePositions = yPositions
    }
    
    private func updateXAxisTextWidth() {
        xDrawAxis?.changeTextWidth(newWidth: dateTextWidth / chartBounds.width)
    }

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
            guard let xDrawAxis = self.xDrawAxis else { return }
            var maxValue: Int = 0
            
            for i in drawLines.indices {
                let drawLine = drawLines[i]

                drawLine.firstIndex = xDrawAxis.firstIndex
                drawLine.lastIndex = xDrawAxis.lastIndex

                for j in drawLine.firstIndex ... drawLine.lastIndex {
                    drawLine.points[j].x = xDrawAxis.points[j].x
                    if !drawLine.isHiding {
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
        guard let xDrawAxis = xDrawAxis else { return }
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        
        context.setLineWidth(0.5)
        if let yDrawAxis = yDrawAxis, gridVisible {
            let allPoints = yDrawAxis.points + yDrawAxis.hidingPoints
            for p in allPoints {
                let normY = maxVisibleY == 0 ? 0 : CGFloat(p.value) / maxVisibleY
                let y = chartBounds.maxY - normY * chartBounds.height
                let height: CGFloat = 18
                let frame = CGRect(x: chartBounds.minX,
                                   y: y - height,
                                   width: chartBounds.width, height: height)
                let attrStr = NSAttributedString(string: p.title,
                                                 attributes: yAxisTextAttributes(alpha: p.alpha))
                attrStr.draw(in: frame)
                
                if p.value == 0 {
                    continue
                } else {
                    context.setStrokeColor(gridAuxColor.withAlphaComponent(p.alpha).cgColor)
                }
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: chartBounds.maxX, y: y))
                context.strokePath()
            }
        }
        
        if gridVisible {
            context.setStrokeColor(gridMainColor.cgColor)
            context.move(to: CGPoint(x: chartBounds.minX, y: chartBounds.maxY))
            context.addLine(to: CGPoint(x: chartBounds.maxX, y: chartBounds.maxY))
            context.strokePath()
            
            let start = max(0, xDrawAxis.firstIndex - xDrawAxis.visibilityStep)
            let end = min(xDrawAxis.lastIndex + xDrawAxis.visibilityStep, xDrawAxis.points.count - 1)
            for i in start ... end {
                let p = xDrawAxis.points[i]
                let height: CGFloat = 18
                let width: CGFloat = 40
                let frame = CGRect(x: chartBounds.minX + p.x * chartBounds.width - dateTextWidth / 2,
                                   y: chartBounds.maxY + 2,
                                   width: width, height: height)
                let attrStr = NSAttributedString(string: p.title,
                                                 attributes: xAxisTextAttributes(alpha: p.alpha))
                attrStr.draw(in: frame)
            }
        }

        if let selectionPos = xDrawAxis.selectionIndex {
            let viewPos = self.chartBounds.minX + xDrawAxis.points[selectionPos].x * self.chartBounds.width
            context.setStrokeColor(gridMainColor.cgColor)
            context.move(to: CGPoint(x: viewPos, y: 0))
            context.addLine(to: CGPoint(x: viewPos, y: chartBounds.maxY))
            context.strokePath()
        }

        context.setLineWidth(lineWidth)
        for line in drawLines ?? [] {
            context.setFillColor(UIColor.clear.cgColor)
            context.setStrokeColor(line.color.withAlphaComponent(line.alpha).cgColor)
            for i in line.firstIndex ... line.lastIndex {
                let normX = line.points[i].x
                let normY = maxVisibleY == 0 ? 0 : CGFloat(line.points[i].value) / maxVisibleY
                let pt = CGPoint(x: self.chartBounds.minX + normX * self.chartBounds.width,
                                 y: self.chartBounds.maxY - normY * self.chartBounds.height)
                if i == line.firstIndex {
                    context.move(to: pt)
                    continue
                } else {
                    context.addLine(to: pt)
                }
            }
            context.strokePath()

            guard !line.isHiding else { continue }
            let radius: CGFloat = 4
            context.setFillColor(backColor.cgColor)
            for i in line.firstIndex ... line.lastIndex {
                guard xDrawAxis.points[i].isSelected else { continue }
                let normX = line.points[i].x
                let normY = maxVisibleY == 0 ? 0 : CGFloat(line.points[i].value) / maxVisibleY
                let rect = CGRect(x: self.chartBounds.minX + normX * self.chartBounds.width - radius,
                                  y: self.chartBounds.maxY - normY * self.chartBounds.height - radius,
                                  width: 2 * radius,
                                  height: 2 * radius)
                context.addEllipse(in: rect)
                context.drawPath(using: .fillStroke)
            }
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
        backColor = theme.cellBackgroundColor
        titleColor = theme.chartTitlesColor
        gridMainColor = theme.chartGridMainColor
        gridAuxColor = theme.chartGridAuxColor
        redraw()
    }
}

// MARK: - Selection View

extension ChartView {

    private func updatePlatePosition() {
        guard !plate.isHidden else { return }
        let inset: CGFloat = 8
        var x = selectionViewPosition
        x = min(x, chartBounds.maxX - plate.frame.width / 2)
        x = max(x, chartBounds.minX + plate.frame.width / 2)
        var y = inset + plate.frame.height / 2
        var overlaps = false
        if let selectedIndex = xDrawAxis?.selectionIndex, let drawLines = drawLines {
            var yPointsToAvoid = [inset, chartBounds.maxY - inset]
            drawLines.forEach { line in
                guard !line.isHiding else { return }
                let normY = maxVisibleY == 0 ? 0 : CGFloat(line.points[selectedIndex].value) / maxVisibleY
                let yView = chartBounds.maxY - normY * chartBounds.height
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
        guard let xDrawAxis = xDrawAxis else { return }
        guard let pos = touches.first?.location(in: self),
            chartBounds.contains(pos),
            !(plate.frame.contains(pos) && !plate.isHidden)
        else {
            hideSelection()
            return
        }
        let chartViewPos = (pos.x - chartBounds.minX) / chartBounds.width
        let normPos = chartViewPos * (xRange.upperBound - xRange.lowerBound) + xRange.lowerBound
        xDrawAxis.selectionIndex = xDrawAxis.getClosestIndex(position: normPos)
        if plate.isHidden {
            showSelection()
        } else {
            moveSelection()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let xDrawAxis = xDrawAxis else { return }
        guard let pos = touches.first?.location(in: self),
            chartBounds.contains(pos) else {
            hideSelection()
            return
        }
        let chartViewPos = (pos.x - chartBounds.minX) / chartBounds.width
        let normPos = chartViewPos * (xRange.upperBound - xRange.lowerBound) + xRange.lowerBound
        xDrawAxis.selectionIndex = xDrawAxis.getClosestIndex(position: normPos)
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
        guard let xDrawAxis = xDrawAxis,
            let selectionIndex = xDrawAxis.selectionIndex else {
            hideSelection()
            return
        }
        let normPos = xDrawAxis.points[selectionIndex].x
        let newPos = self.chartBounds.minX + normPos * self.chartBounds.width
        
        if normPos <= 0 || normPos >= 1 {
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
            self.xDrawAxis?.selectionIndex = nil
            self.plate.isHidden = true
            self.redraw()
        }
    }

    private func getChartCurrentData() -> (Date, [(Int, UIColor)])? {
        guard let drawLines = drawLines,
            let xDrawAxis = xDrawAxis,
            let selectionIndex = xDrawAxis.selectionIndex else {
            return nil
        }
        let date = xDrawAxis.points[selectionIndex].value
        var numbers = [(Int, UIColor)]()
        for drawLine in drawLines {
            guard !drawLine.isHiding else { continue }
            let number = drawLine.points[selectionIndex].value
            let color = drawLine.color
            numbers.append((number, color))
        }
        return (date, numbers)
    }
}
