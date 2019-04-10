//
//  GraphModel.swift
//  TelegramCharts
//
//  Created by Rost on 17/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import Foundation

struct GraphModel {
    let columns: [String: [Int]]
    let names: [String: String]
    let types: [String: String]
    let colors: [String: String]
    let stacked: Bool
    let y_scaled: Bool
    let percentage: Bool
}

extension GraphModel: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        colors = try container.decode(type(of: colors).self, forKey: .colors)
        names = try container.decode(type(of: names).self, forKey: .names)
        types = try container.decode(type(of: types).self, forKey: .types)
        
        stacked = (try? container.decode(type(of: stacked).self, forKey: .stacked)) ?? false
        y_scaled = (try? container.decode(type(of: y_scaled).self, forKey: .y_scaled)) ?? false
        percentage = (try? container.decode(type(of: y_scaled).self, forKey: .percentage)) ?? false
        
        var columnsContainer = try container.nestedUnkeyedContainer(forKey: .columns)
        var columns = [String: [Int]]()
        while !columnsContainer.isAtEnd {
            var columnContainer = try columnsContainer.nestedUnkeyedContainer()
            let name = try columnContainer.decode(String.self)
            columns[name] = [Int]()
            while !columnContainer.isAtEnd {
                columns[name]?.append(try columnContainer.decode(Int.self))
            }
        }
        self.columns = columns
    }
}
