//
//  SelectionView.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 19/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class SelectionView: UIView {

    private let viewHeight: CGFloat = 60
    private let dateWidth: CGFloat = 80

    var date: Date?
    private var numbers: [(Int64, UIColor)]?

    private var dateAttributedString: NSAttributedString?
    private var dateStringFrame: CGRect = .zero
    private var numbersAttributedString: NSAttributedString?
    private var numbersStringFrame: CGRect = .zero

    private var position: CGFloat = 0

    var plate: PlateView!
    private var lineView: UIView!

    func updatePosition(pos: CGFloat) {
        self.position = pos
        recalculatePosition()
    }

    func updateData(date: Date, numbers: [(Int64, UIColor)]) {
        self.date = date
        self.numbers = numbers
        plate.update(date: date, numbers: numbers)
        recalculatePosition()
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    private func initialSetup() {
        backgroundColor = .clear
        plate = PlateView(frame: .zero)
        plate.layer.cornerRadius = 2.0
        plate.layer.masksToBounds = true
        addSubview(plate)
        lineView = UIView(frame: .zero)
        addSubview(lineView)
        startReceivingThemeUpdates()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        recalculatePosition()
    }

    deinit {
        stopReceivingThemeUpdates()
    }

    // MARK: - Private

    private func recalculatePosition() {
        plate.center = CGPoint(x: position, y: 16)
        lineView.frame = CGRect(x: position,
                                y: plate.frame.maxY,
                                width: 0.5,
                                height: bounds.height - plate.frame.maxY)
    }
}

// MARK: Stylable

extension SelectionView: Stylable {

    func themeDidUpdate(theme: Theme) {
        lineView.backgroundColor = theme.chartGridMainColor
        setNeedsDisplay()
    }
}

class PlateView: UIView {

    var dateAttributedString: NSAttributedString?
    var numbersAttributedString: NSAttributedString?
    var dateStringFrame: CGRect = .zero
    var numbersStringFrame: CGRect = .zero

    private var dateTextColor: UIColor = .black

    private var date: Date?
    private var numbers: [(Int64, UIColor)]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        startReceivingThemeUpdates()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startReceivingThemeUpdates()
    }

    deinit {
        stopReceivingThemeUpdates()
    }

    func update(date: Date, numbers: [(Int64, UIColor)]?) {
        self.date = date
        self.numbers = numbers
        resetDateAttributedString()
        resetNumberAttributedString()
        recalculateSize()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let dateAttributedString = dateAttributedString,
            let numbersAttributedString = numbersAttributedString else {
                return
        }
        dateAttributedString.draw(in: dateStringFrame)
        numbersAttributedString.draw(in: numbersStringFrame)
    }

    private func recalculateSize() {
        let inset: CGFloat = 4
        guard let height = dateAttributedString?.height(withConstrainedWidth: .greatestFiniteMagnitude),
            let dateWidth = dateAttributedString?.width(withConstrainedHeight: height),
            let numbersWidth = numbersAttributedString?.width(withConstrainedHeight: height)
            else {
                return
        }
        let totalWidth = dateWidth + numbersWidth + 3 * inset
        let totalHeight = height + 2 * inset
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: totalWidth, height: totalHeight)
        dateStringFrame = CGRect(x: inset, y: inset, width: dateWidth, height: height)
        numbersStringFrame = CGRect(x: dateStringFrame.maxX + inset, y: inset, width: numbersWidth, height: height)
        setNeedsDisplay()
    }

    private func resetDateAttributedString() {
        guard let date = date else {
            dateAttributedString = nil
            return
        }
        let topLineAttribs: [NSAttributedString.Key: Any] = [
            .foregroundColor: dateTextColor,
            .font: UIFont.boldSystemFont(ofSize: 12)
        ]
        let bottomLineAttribs: [NSAttributedString.Key: Any] = [
            .foregroundColor: dateTextColor,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        let topLineText = NSAttributedString(string: date.monthDayShortString(), attributes: topLineAttribs)
        let bottomLineText = NSAttributedString(string: date.yearString(), attributes: bottomLineAttribs)
        let nlText = NSAttributedString(string: "\n")
        let result = NSMutableAttributedString(attributedString: topLineText)
        result.append(nlText)
        result.append(bottomLineText)
        dateAttributedString = result.copy() as? NSAttributedString
    }

    private func resetNumberAttributedString() {
        guard let numbers = numbers else {
            numbersAttributedString = nil
            return
        }
        let topLineText = NSMutableAttributedString()
        let bottomLineText = NSMutableAttributedString()
        for i in numbers.indices {
            let number = numbers[i].0
            let color = numbers[i].1
            let attribs: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .font: UIFont.boldSystemFont(ofSize: 12)
            ]
            let text = NSAttributedString(string: String(number) + " ", attributes: attribs)
            if i % 2 == 0 {
                topLineText.append(text)
            } else {
                bottomLineText.append(text)
            }
        }
        let nlText = NSAttributedString(string: "\n")
        let result = NSMutableAttributedString(attributedString: topLineText)
        result.append(nlText)
        result.append(bottomLineText)
        numbersAttributedString = result.copy() as? NSAttributedString
    }
}

extension PlateView: Stylable {

    func themeDidUpdate(theme: Theme) {
        dateTextColor = theme.chartTitlesColor
        backgroundColor = theme.viewBackgroundColor
        resetDateAttributedString()
        resetNumberAttributedString()
        setNeedsDisplay()
    }
}
