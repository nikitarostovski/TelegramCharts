//
//  ChartView.swift
//  TelegramCharts
//
//  Created by Rost on 11/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

// TODO: shorten thousands to *k and so on

struct ChartData {
    var values: [Int64]
    var color: UIColor
}

class ChartView: UIView, Stylable {
    
    var charts = [ChartData]() {
        didSet {
            setupView()
            redraw()
        }
    }
    var visibleRange = 0.0...1.0 {
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
    
    private var chartLayers = [CAShapeLayer]()
    
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
        chartLayers = [CAShapeLayer]()
        charts.forEach { [weak self] (chart) in
            let layer = CAShapeLayer()
            layer.lineWidth = lineWidth
            layer.lineJoin = .round
            layer.lineCap = .round
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = chart.color.cgColor
            self?.chartLayers.append(layer)
            self?.layer.addSublayer(layer)
        }
    }
    
    // TODO: split to recalc and redraw funcs
    private func redraw() {
        for chartIndex in 0 ..< charts.count {
            let chart = charts[chartIndex]
            
            let startPosition = CGFloat(chart.values.count - 1) * CGFloat(visibleRange.lowerBound)
            let endPosition = CGFloat(chart.values.count - 1) * CGFloat(visibleRange.upperBound)
            
            var startIndex: Int?
            var endIndex: Int?
            
            var viewPositions = [CGFloat]()
            for i in 0 ..< chart.values.count {
                let newPos = (CGFloat(i) - startPosition) / (endPosition - startPosition) * self.frame.size.width
                viewPositions.append(newPos)
                
                if newPos < 0 {
                    startIndex = i
                }
                if newPos > self.frame.size.width && endIndex == nil {
                    endIndex = i
                }
            }
            
            if startIndex == nil {
                startIndex = 0
            }
            if endIndex == nil {
                endIndex = chart.values.count - 1
            }
            
            var maxY: Int64 = 0
            for i in startIndex! ... endIndex! {
                maxY = max(maxY, chart.values[i])
            }
            
            let path = UIBezierPath()
            for i in startIndex! ..< endIndex! {
                let viewX = viewPositions[i]
                let viewY = self.frame.size.height - CGFloat(chart.values[i]) * self.frame.size.height / CGFloat(maxY)
                let point = CGPoint(x: viewX, y: viewY)
                
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            
            let layer = chartLayers[chartIndex]
            layer.path = path.cgPath
        }
    }
    
    func themeDidUpdate(theme: Theme) {
        backgroundColor = theme.cellBackgroundColor
    }
}
