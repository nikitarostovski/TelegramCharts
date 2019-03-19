//
//  PlateView.swift
//  TelegramCharts
//
//  Created by Nikita Rostovskiy on 19/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class PlateView: UIView {

    var dateAttributedString: NSAttributedString?
    var dateStringFrame: CGRect = .zero
    
    var numbersAttributedStrings: [NSAttributedString]?
    var numbersStringFrames = [CGRect]()

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
        startReceivingThemeUpdates()
    }

    deinit {
        stopReceivingThemeUpdates()
    }

    func update(date: Date, numbers: [(Int, UIColor)]?) {
        self.date = date
        self.numbers = numbers
        resetDateAttributedString()
        resetNumberAttributedString()
        recalculateSize()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let dateAttributedString = dateAttributedString,
            let numbersAttributedStrings = numbersAttributedStrings else {
                return
        }
        dateAttributedString.draw(in: dateStringFrame)
        if numbersAttributedStrings.count == numbersStringFrames.count {
            for i in numbersAttributedStrings.indices {
                numbersAttributedStrings[i].draw(in: numbersStringFrames[i])
            }
        }
    }

     func recalculateSize() {
        let inset: CGFloat = 4
        guard let strings = numbersAttributedStrings,
            let height = dateAttributedString?.height(withConstrainedWidth: .greatestFiniteMagnitude),
            let dateWidth = dateAttributedString?.width(withConstrainedHeight: height)
            else {
                return
        }
        dateStringFrame = CGRect(x: inset, y: inset, width: dateWidth, height: height)
        
        var numbersTotalWidth: CGFloat = 0
        for i in strings.indices {
            let columnWidth = strings[i].width(withConstrainedHeight: height)
            let frame = CGRect(x: dateStringFrame.maxX + inset + numbersTotalWidth, y: inset, width: columnWidth, height: height)
            numbersStringFrames.append(frame)
            numbersTotalWidth += columnWidth
        }
        
        let totalWidth = dateWidth + numbersTotalWidth + 3 * inset
        let totalHeight = height + 2 * inset
        frame = CGRect(x: center.x - totalWidth / 2,
                       y: center.y - totalHeight / 2,
                       width: totalWidth,
                       height: totalHeight)
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
            numbersAttributedStrings = nil
            return
        }
        var columnTexts = [NSMutableAttributedString]()
        var currentText: NSMutableAttributedString?
        var currentDelimeterText: NSMutableAttributedString?
        for i in numbers.indices {
            if i % 2 == 0 {
                currentText = NSMutableAttributedString()
                currentDelimeterText = NSMutableAttributedString(string: "\n")
            } else {
                currentDelimeterText = nil
            }
            let number = numbers[i].0
            let color = numbers[i].1
            let attribs: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .font: UIFont.boldSystemFont(ofSize: 12)
            ]
            let text = NSAttributedString(string: String(number: number), attributes: attribs)
            currentText!.append(text)
            if currentDelimeterText != nil {
                currentText!.append(currentDelimeterText!)
            }
            if i % 2 == 1 {
                columnTexts.append(currentText!)
            }
        }
        numbersAttributedStrings = columnTexts
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
