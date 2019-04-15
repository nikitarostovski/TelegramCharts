//
//  TintView.swift
//  TelegramCharts
//
//  Created by Rost on 13/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class TintView: UIView {
    
    var insetLeft: CGFloat = 16
    var insetRight: CGFloat = 16
    
    private var fillLayer: CAShapeLayer?
    private var gradientLayer: CAGradientLayer?
    private var gradientColor: UIColor = .red

    init() {
        super.init(frame: .zero)
        startReceivingThemeUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopReceivingThemeUpdates()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let x1 = insetLeft / bounds.width
        let x2 = (bounds.width - insetRight) / bounds.width
        updateTint(x1: x1, x2: x2)
    }
    
    private func updateTint(x1: CGFloat, x2: CGFloat) {
        fillLayer?.removeFromSuperlayer()
        self.gradientLayer?.removeFromSuperlayer()
        
        fillLayer = CAShapeLayer()
        fillLayer!.fillColor = gradientColor.cgColor
        fillLayer!.path = UIBezierPath(rect: bounds).cgPath
        fillLayer!.frame = bounds
        layer.addSublayer(fillLayer!)
        
        let colors: [CGColor] = [UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor]
        let locations: [NSNumber] = [0.0, NSNumber(value: Double(x1)), NSNumber(value: Double(x2)), 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = locations
        gradientLayer.colors = colors
        gradientLayer.frame = fillLayer!.bounds

        fillLayer!.mask = gradientLayer
    }
}

extension TintView: Stylable {
    
    func themeDidUpdate(theme: Theme) {
        gradientColor = theme.cellBackgroundColor
        fillLayer?.fillColor = theme.cellBackgroundColor.cgColor
    }
}
