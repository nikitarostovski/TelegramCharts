//
//  PlateView.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 19/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class PlateView: UIView {


    var labels = [UILabel]()

    private var dateTextColor: UIColor = .black

    private var date: Date?
    private var numbers: [(Int, UIColor)]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        layer.cornerRadius = 2
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        startReceivingThemeUpdates()
    }

    deinit {
        stopReceivingThemeUpdates()
    }

    func update(date: Date, numbers: [(Int, UIColor)]?) {
        self.date = date
        self.numbers = numbers
        resetTexts()
        recalculateSize()
    }

    func resetTexts() {
        guard let numbers = self.numbers else {
            return
        }
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll()

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.attributedText = dateAttributedString()
        labels.append(label)
        addSubview(label)

        for i in 0 ..< numbers.count {
            if i % 2 == 0 {
                var columnNumbers = [numbers[i]]
                if i + 1 < numbers.count {
                    columnNumbers.append(numbers[i + 1])
                }
                let label = UILabel(frame: .zero)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 2
                label.attributedText = numberAttributedString(numberTitles: columnNumbers)
                labels.append(label)
                addSubview(label)
            }
        }
    }

    func recalculateSize() {
        let inset: CGFloat = 4
        let dateTextWidth: CGFloat = 48
        let numberTextWidth: CGFloat = 28
        let textHeight: CGFloat = 15

        var maxLabelHeight: CGFloat = 0
        var biggestLabelIndex = 0
        for i in labels.indices {
            let label = labels[i]
            var left = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: inset)
            var textWidth = dateTextWidth
            var correctedTextHeight = textHeight
            if label.attributedText?.string.range(of: "\n") != nil {
                correctedTextHeight *= 2
            }
            if correctedTextHeight > maxLabelHeight {
                maxLabelHeight = correctedTextHeight
                biggestLabelIndex = i
            }
            if i > 0 {
                if let text = label.attributedText {
                    textWidth = text.width(withConstrainedHeight: correctedTextHeight)
                } else {
                    textWidth = numberTextWidth
                }
                left = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: labels[i - 1], attribute: .trailing, multiplier: 1, constant: inset)
            }
            let top = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: inset)
            let height = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: correctedTextHeight)
            let width = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textWidth)

            self.addConstraints([top, height, width, left])

            if i == labels.count - 1 {
                let right = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -inset)
                self.addConstraint(right)
            }
        }
        let biggestLabel = labels[biggestLabelIndex]
        let bottom = NSLayoutConstraint(item: biggestLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -inset)
        self.addConstraint(bottom)
    }

    private func dateAttributedString() -> NSAttributedString? {
        guard let date = date else {
            return nil
        }
        let topLineAttribs: [NSAttributedString.Key: Any] = [
            .foregroundColor: dateTextColor,
            .font: UIFont.boldSystemFont(ofSize: 12)
        ]
        let bottomLineAttribs: [NSAttributedString.Key: Any] = [
            .foregroundColor: dateTextColor,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        let topLineText = NSAttributedString(string: date.string(format: .monthDay), attributes: topLineAttribs)
        let bottomLineText = NSAttributedString(string: date.string(format: .year), attributes: bottomLineAttribs)
        let nlText = NSAttributedString(string: "\n")
        let result = NSMutableAttributedString(attributedString: topLineText)
        result.append(nlText)
        result.append(bottomLineText)
        return result.copy() as? NSAttributedString
    }

    private func numberAttributedString(numberTitles: [(Int, UIColor)]) -> NSAttributedString? {
        let currentText = NSMutableAttributedString()
        let currentDelimeterText = NSMutableAttributedString(string: "\n")
        for i in numberTitles.indices {
            let number = numberTitles[i].0
            let color = numberTitles[i].1
            let attribs: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .font: UIFont.boldSystemFont(ofSize: 12)
            ]
            let text = NSAttributedString(string: String(number: number), attributes: attribs)
            currentText.append(text)
            if i != numberTitles.count - 1 {
                currentText.append(currentDelimeterText)
            }
        }
        return currentText.copy() as? NSAttributedString
    }
}

extension PlateView: Stylable {

    func themeDidUpdate(theme: Theme) {
        dateTextColor = theme.chartTitlesColor
        backgroundColor = theme.viewBackgroundColor
        resetTexts()
    }
}
