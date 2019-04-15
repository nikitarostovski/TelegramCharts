//
//  FilterButton.swift
//  TelegramCharts
//
//  Created by SBRF on 12/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class FilterButton: UIButton {
    
    var onTap: ((_ button: FilterButton) -> ())?
    
    private var fillLayer: CAShapeLayer?
    private var borderLayer: CAShapeLayer?
    
    var color: UIColor = .clear {
        didSet {
            updateStyle()
        }
    }
    var isOn: Bool = false {
        didSet {
            updateStyle()
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:)") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        fillLayer = CAShapeLayer()
        fillLayer!.masksToBounds = true
        fillLayer!.cornerRadius = 4
        layer.addSublayer(fillLayer!)
        
        borderLayer = CAShapeLayer()
        borderLayer!.fillColor = UIColor.clear.cgColor
        borderLayer!.masksToBounds = true
        borderLayer!.cornerRadius = 4
        borderLayer!.lineWidth = 3
        layer.addSublayer(borderLayer!)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let visibleBounds = layer.bounds.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        if let fillLayer = fillLayer {
            fillLayer.frame = visibleBounds
            fillLayer.path = UIBezierPath(roundedRect: fillLayer.bounds, cornerRadius: fillLayer.cornerRadius).cgPath
        }
        if let borderLayer = borderLayer {
            borderLayer.frame = visibleBounds
            borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: borderLayer.cornerRadius).cgPath
        }
    }
    
    func setupButton() {
        addTarget(self, action: #selector(touchUp(sender:)), for: [.touchUpInside])
    }
    
    @objc func touchUp(sender: FilterButton) {
        onTap?(sender)
    }
    
    private func updateStyle() {
        borderLayer?.strokeColor = color.cgColor
        if isOn {
            fillLayer?.fillColor = color.cgColor
            setTitleColor(.white, for: .normal)
        } else {
            fillLayer?.fillColor = UIColor.clear.cgColor
            setTitleColor(color, for: .normal)
        }
    }
}
