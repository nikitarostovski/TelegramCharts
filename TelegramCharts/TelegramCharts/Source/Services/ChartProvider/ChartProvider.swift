//
//  ChartProvider.swift
//  TelegramCharts
//
//  Created by Rost on 17/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class ChartProvider {
    
    static private let fileName = "chart_data.json"
    
    static func getCharts() -> [Chart]? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            return nil
        }
        guard let data = NSData(contentsOfFile: path) as Data? else {
            return nil
        }
        do {
            let results = try JSONDecoder().decode([Chart].self, from: data)
            return results
        } catch {
            return nil
        }
    }
}
