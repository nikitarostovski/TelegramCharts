//
//  FilterButton.swift
//  TelegramCharts
//
//  Created by SBRF on 12/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class FilterButton: UIButton {
    
    private var setup = false
    private let animDuration = 0.05
    private let animInset: CGFloat = 1
    
    var onTap: ((_ button: FilterButton) -> ())?
    var onLongTap: ((_ button: FilterButton) -> ())?
    
    private var fillLayer: CAShapeLayer?
    private var borderLayer: CAShapeLayer?
    
    var color: UIColor = .clear {
        didSet {
            updateStyle()
        }
    }
    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else { return }
            updateStyle()
            if let fillLayer = fillLayer, setup  {
                let tapAnim = CABasicAnimation()
                tapAnim.duration = animDuration
                tapAnim.autoreverses = true
                tapAnim.fromValue = fillLayer.bounds
                tapAnim.toValue = fillLayer.bounds.insetBy(dx: animInset, dy: animInset)
                fillLayer.add(tapAnim, forKey: "bounds")
            }
            if let borderLayer = borderLayer, setup  {
                let tapAnim = CABasicAnimation()
                tapAnim.duration = animDuration
                tapAnim.autoreverses = true
                tapAnim.fromValue = borderLayer.bounds
                tapAnim.toValue = borderLayer.bounds.insetBy(dx: animInset, dy: animInset)
                borderLayer.add(tapAnim, forKey: "bounds")
            }
        }
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = animDuration * 6
        animation.values = [-animInset * 3, animInset * 3, -animInset * 3, animInset * 3, -animInset * 2, animInset * 2, -animInset, animInset, 0]
        layer.add(animation, forKey: "shake")
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
        setup = true
    }
    
    private func setupButton() {
        addTarget(self, action: #selector(touchUp(sender:)), for: [.touchUpInside])
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTap(sender:))))
    }
    
    @objc func touchUp(sender: FilterButton) {
        onTap?(sender)
    }
    
    @objc func longTap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            onLongTap?(self)
        }
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
