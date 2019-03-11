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

class ChartView: UIView {
    
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
    
    private var chartLayers = [CAShapeLayer]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    private func setupView() {
        chartLayers.forEach { $0.removeFromSuperlayer() }
        chartLayers = [CAShapeLayer]()
        charts.forEach { [weak self] (chart) in
            let layer = CAShapeLayer()
            layer.lineWidth = 4
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
            
            var viewPositions = [CGFloat]()
            for i in 0 ..< chart.values.count {
                viewPositions.append((CGFloat(i) - startPosition) / (endPosition - startPosition) * self.frame.size.width)
            }
            
            let path = UIBezierPath()
            for i in 0 ..< chart.values.count {
                let viewX = viewPositions[i]
                let viewY = self.frame.size.height - CGFloat(chart.values[i]) * self.frame.size.height / CGFloat(10)
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
}
