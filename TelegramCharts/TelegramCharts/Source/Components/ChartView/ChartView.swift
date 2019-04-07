//
//  ChartView.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

typealias ChartLine = (values: [Int], color: UIColor, name: String)

protocol ChartViewDataSource {
    var visibleIndices: [Int] { get }
    var yDrawAxis: ChartDrawAxisY { get }
    var xDrawAxis: ChartDrawAxisX { get }
    var drawLines: [ChartDrawLine] { get }
    var range: ClosedRange<CGFloat> { get }
    var maxVisibleY: CGFloat { get }
    var maxTotalVisibleY: CGFloat { get }
    
    var gridMainColor: UIColor { get }
    var gridAuxColor: UIColor { get }
    var backColor: UIColor { get }
    
    var plateData: (Date, [(Int, UIColor)])? { get }
    
    func viewSizeChanged(newSize: CGSize)
}

class ChartView: UIView {

    private var dataSource: ChartViewDataSource
    private var lineWidth: CGFloat
    private var gridVisible: Bool
    private var isMap: Bool

    var chartInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

    private var chartBounds: CGRect = .zero
    
    private var plate: PlateView!
    private var selectionViewPosition: CGFloat! {
        didSet {
            updatePlatePosition()
        }
    }
    
    // MARK: - Lifecycle

    init(dataSource: ChartViewDataSource, lineWidth: CGFloat, isMap: Bool) {
        self.isMap = isMap
        self.gridVisible = !isMap
        self.lineWidth = lineWidth
        self.dataSource = dataSource

        plate = PlateView(frame: .zero)
        plate.isHidden = true
        plate.alpha = 0
        super.init(frame: .zero)

        addSubview(plate)
        backgroundColor = .clear
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        chartBounds = self.bounds.inset(by: chartInsets)
        dataSource.viewSizeChanged(newSize: chartBounds.size)
        updatePlatePosition()
    }
    
    // MARK: - Private
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        
        context.setLineWidth(0.5)
        if gridVisible {
            let allPoints = dataSource.yDrawAxis.points + dataSource.yDrawAxis.hidingPoints
            for p in allPoints {
                let normY = dataSource.maxVisibleY == 0 ? 0 : CGFloat(p.value) / dataSource.maxVisibleY
                let y = chartBounds.maxY - normY * chartBounds.height
                let height: CGFloat = 18
                let frame = CGRect(x: chartBounds.minX,
                                   y: y - height,
                                   width: chartBounds.width, height: height)
                context.setAlpha(p.alpha)
                p.title.draw(in: frame)
                
                if p.value == 0 {
                    continue
                } else {
                    context.setStrokeColor(dataSource.gridAuxColor.cgColor)
                }
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: chartBounds.maxX, y: y))
                context.strokePath()
            }
            context.setAlpha(1)
        }
        
        if gridVisible {
            context.setStrokeColor(dataSource.gridMainColor.cgColor)
            context.move(to: CGPoint(x: chartBounds.minX, y: chartBounds.maxY))
            context.addLine(to: CGPoint(x: chartBounds.maxX, y: chartBounds.maxY))
            context.strokePath()
            for i in dataSource.xDrawAxis.points.indices {
                let p = dataSource.xDrawAxis.points[i]
                guard p.alpha > 0.01 else { continue }
                let x = chartBounds.minX + p.x * chartBounds.width - p.titleWidth / 2
                
                let height: CGFloat = 18
                let frame = CGRect(x: x,
                                   y: chartBounds.maxY + 2,
                                   width: p.titleWidth, height: height)
                context.setAlpha(p.alpha)
                p.title.draw(in: frame)
            }
        }
        context.setAlpha(1)

        if gridVisible,
            let selectionPos = dataSource.xDrawAxis.selectionIndex {
            
            let viewPos = self.chartBounds.minX + dataSource.xDrawAxis.points[selectionPos].x * self.chartBounds.width
            context.setStrokeColor(dataSource.gridMainColor.cgColor)
            context.move(to: CGPoint(x: viewPos, y: 0))
            context.addLine(to: CGPoint(x: viewPos, y: chartBounds.maxY))
            context.strokePath()
        }

        context.setLineWidth(lineWidth)
        for line in dataSource.drawLines {
            context.setFillColor(UIColor.clear.cgColor)
            context.setStrokeColor(line.color.withAlphaComponent(line.alpha).cgColor)
            
            var indices = Array(0 ... line.points.count - 1)
            var maxY = CGFloat(dataSource.maxTotalVisibleY)
            if !isMap {
                indices = dataSource.visibleIndices
                maxY = dataSource.maxVisibleY
            }
            var points = [CGPoint]()
            for i in indices {
                var normX: CGFloat
                if isMap {
                    normX = dataSource.xDrawAxis.points[i].originalX
                } else {
                    normX = dataSource.xDrawAxis.points[i].x
                }
                let normY = maxY == 0 ? 0 : CGFloat(line.points[i].value) / maxY
                let pt = CGPoint(x: self.chartBounds.minX + normX * self.chartBounds.width,
                                 y: self.chartBounds.maxY - normY * self.chartBounds.height)
                points.append(pt)
            }
//            points = Simplifier.simplify(points, tolerance: line.tolerance)
            for i in points.indices {
                let pt = points[i]
                if i == 0 {
                    context.move(to: pt)
                    continue
                } else {
                    context.addLine(to: pt)
                }
            }
            context.strokePath()
            
            guard gridVisible, !line.isHiding else { continue }
            let radius: CGFloat = 4
            context.setFillColor(dataSource.backColor.cgColor)
            for i in dataSource.visibleIndices {
                guard dataSource.xDrawAxis.points[i].isSelected else { continue }
                let normX = dataSource.xDrawAxis.points[i].x
                let normY = dataSource.maxVisibleY == 0 ? 0 : CGFloat(line.points[i].value) / dataSource.maxVisibleY
                let rect = CGRect(x: self.chartBounds.minX + normX * self.chartBounds.width - radius,
                                  y: self.chartBounds.maxY - normY * self.chartBounds.height - radius,
                                  width: 2 * radius,
                                  height: 2 * radius)
                context.addEllipse(in: rect)
                context.drawPath(using: .fillStroke)
            }
        }
    }
    
    func redraw() {
        setNeedsDisplay()
    }
}

// MARK: - Selection View

extension ChartView {

    private func updatePlatePosition() {
        guard !plate.isHidden else { return }
        let inset: CGFloat = 8
        var x = selectionViewPosition ?? 0
        x = min(x, chartBounds.maxX - plate.frame.width / 2)
        x = max(x, chartBounds.minX + plate.frame.width / 2)
        var y = inset + plate.frame.height / 2
        var overlaps = false
        if let selectedIndex = dataSource.xDrawAxis.selectionIndex {
            let drawLines = dataSource.drawLines
            var yPointsToAvoid = [inset, chartBounds.maxY - inset]
            drawLines.forEach { line in
                guard !line.isHiding else { return }
                let normY = dataSource.maxVisibleY == 0 ? 0 : CGFloat(line.points[selectedIndex].value) / dataSource.maxVisibleY
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
        guard let pos = touches.first?.location(in: self),
            chartBounds.contains(pos),
            !(plate.frame.contains(pos) && !plate.isHidden)
        else {
            hideSelection()
            return
        }
        let chartViewPos = (pos.x - chartBounds.minX) / chartBounds.width
        let normPos = chartViewPos * (dataSource.range.upperBound - dataSource.range.lowerBound) + dataSource.range.lowerBound
        dataSource.xDrawAxis.selectionIndex = dataSource.xDrawAxis.getClosestIndex(position: normPos)
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
        let normPos = chartViewPos * (dataSource.range.upperBound - dataSource.range.lowerBound) + dataSource.range.lowerBound
        dataSource.xDrawAxis.selectionIndex = dataSource.xDrawAxis.getClosestIndex(position: normPos)
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

    func moveSelection(animated: Bool = true) {
        guard !plate.isHidden else { return }
        guard let selectionIndex = dataSource.xDrawAxis.selectionIndex else {
            hideSelection()
            return
        }
        let normPos = dataSource.xDrawAxis.points[selectionIndex].x
        let newPos = self.chartBounds.minX + normPos * self.chartBounds.width
        
        if normPos <= 0 || normPos >= 1 {
            hideSelection()
            return
        }
        if let data = dataSource.plateData {
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
            self.dataSource.xDrawAxis.selectionIndex = nil
            self.plate.isHidden = true
            self.redraw()
        }
    }
}
