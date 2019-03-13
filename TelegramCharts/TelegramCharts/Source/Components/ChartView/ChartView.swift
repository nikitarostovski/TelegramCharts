//
//  ChartView.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

// TODO: shorten thousands to *k and so on

struct ChartsData {
    var dates = [Date]()
    var lines = [LineData]()
}

struct LineData {
    var values: [Int64]
    var color: UIColor
}

class ChartLineLayer: CAShapeLayer {

    override func action(forKey event: String) -> CAAction? {
        guard event == "path" else {
            return super.action(forKey: event)
        }
        let animation = CABasicAnimation(keyPath: event)
        animation.duration = CATransaction.animationDuration()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
}

class ChartView: UIView, Stylable {

    var charts = ChartsData() {
        didSet {
            setupView()
            redraw()
        }
    }
    var visibleRange: ClosedRange<CGFloat> = 0 ... 1 {
        didSet {
            redraw()
        }
    }
    
    var lineWidth: CGFloat = 4.0 {
        didSet {
            chartLayers.forEach {
                $0.lineWidth = lineWidth
            }
            redraw()
        }
    }
    
    private var chartLayers = [ChartLineLayer]()
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        startReceivingThemeUpdates()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        startReceivingThemeUpdates()
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        redraw()
    }
    
    // MARK: - Private

    private func setupView() {
        chartLayers.forEach { $0.removeFromSuperlayer() }
        chartLayers = [ChartLineLayer]()
        charts.lines.forEach { [weak self] line in
            var isFirst = true
            line.values.forEach { value in
                guard !isFirst else {
                    isFirst = false
                    return
                }
                let layer = ChartLineLayer()
                layer.lineWidth = lineWidth
                layer.lineJoin = .round
                layer.lineCap = .round
                layer.fillColor = UIColor.clear.cgColor
                layer.strokeColor = line.color.cgColor
                self?.chartLayers.append(layer)
                self?.layer.addSublayer(layer)
            }
        }
    }

    private func redraw() {
        let chartViewData = viewCharts

        for lineIndex in 0 ..< chartViewData.lines.count {
            let line = chartViewData.lines[lineIndex]

            var lastPoint = CGPoint.zero
            for valueIndex in 0 ..< line.values.count {
                let value = line.values[valueIndex]
                let posX = value.xPos * bounds.width
                let posY = value.yPos * bounds.height
                let point = CGPoint(x: posX, y: posY)

                if valueIndex == 0 {
                    lastPoint = point
                    continue
                }

                let linePath = UIBezierPath()
                linePath.move(to: lastPoint)
                linePath.addLine(to: point)

                let layer = chartLayers[lineIndex * (line.values.count - 1) + valueIndex - 1]

                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = 0.5
                animation.toValue = linePath.cgPath

                layer.path = linePath.cgPath
                layer.add(animation, forKey: "pathAnimation")

                lastPoint = point
            }
        }
    }
    
    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
    }
}

// MARK: - dynamic calculations

extension ChartView {

    private struct ChartsViewData {
        var dates = [DateViewData]()
        var lines = [LineViewData]()
    }

    private struct LineViewData {
        var values: [ValueViewData]
        var color: UIColor
    }

    private struct ValueViewData {
        var value: Int64
        var xPos: CGFloat
        var yPos: CGFloat
    }

    private struct DateViewData {
        var value: Date
        var xPos: CGFloat
    }

    private var viewCharts: ChartsViewData {
        let scale = (visibleRange.upperBound - visibleRange.lowerBound) / CGFloat(charts.dates.count)

        var dates = [DateViewData]()
        for i in 0 ..< charts.dates.count {
            let xPos: CGFloat = CGFloat(i) * scale - visibleRange.lowerBound
            let dateViewData = DateViewData(value: charts.dates[i], xPos: xPos)
            dates.append(dateViewData)
        }

        var lines = [LineViewData]()
        charts.lines.forEach {
            var values = [ValueViewData]()
            var maxVisibleValue: Int64 = 0
            for i in 0 ..< $0.values.count {
                let normX = CGFloat(i) / CGFloat($0.values.count)
                let xPos: CGFloat = (normX - visibleRange.lowerBound) / (visibleRange.upperBound - visibleRange.lowerBound)
                let valueViewData = ValueViewData(value: $0.values[i], xPos: xPos, yPos: 0)
                values.append(valueViewData)
            }
            values.forEach {
                guard $0.xPos >= 0 && $0.xPos <= 1 else { return }
                maxVisibleValue = max(maxVisibleValue, $0.value)
            }
            values = values.map {
                let yPos = CGFloat($0.value) / CGFloat(maxVisibleValue)
                return ValueViewData(value: $0.value, xPos: $0.xPos, yPos: yPos)
            }
            let lineViewData = LineViewData(values: values, color: $0.color)
            lines.append(lineViewData)
        }
        return ChartsViewData(dates: dates, lines: lines)
    }
}
