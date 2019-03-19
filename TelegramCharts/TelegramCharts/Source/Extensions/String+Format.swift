//
//  String+Format.swift
//  TelegramCharts
//
//  Created by Rost on 19/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

extension String {
    
    private static let suffix = ["", "k", "m", "b", "t", "p", "e"]

    init(number: Int) {
        var index = 0
        var value = number
        while (value / 1000 >= 1) {
            value /=  1000
            index += 1
        }
        self = String(format: "%d%@", value, String.suffix[index])
    }

}
