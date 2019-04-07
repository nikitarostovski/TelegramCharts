//
//  String+Format.swift
//  TelegramCharts
//
//  Created by Rost on 19/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

extension String {
    
    init(decimal: Int) {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        self = formatter.string(from: NSNumber(integerLiteral: decimal)) ?? String(decimal)
    }

    init(number: Int) {
        let numFormatter = NumberFormatter()

        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (100_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]

        let startValue = Double(abs(number))
        let abbreviation: Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()

        let value = Double(number) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        numFormatter.decimalSeparator = "."

        self = numFormatter.string(from: NSNumber(floatLiteral: value)) ?? ""
    }

}
