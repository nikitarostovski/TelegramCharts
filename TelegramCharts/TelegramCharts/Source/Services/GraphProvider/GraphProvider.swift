//
//  GraphProvider.swift
//  TelegramCharts
//
//  Created by Rost on 17/03/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class GraphProvider {
    
    static private let files = [
        "overview1.json",
        "overview2.json",
        "overview3.json",
        "overview4.json",
        "overview5.json"
    ]
    
    static private let titles = [
        "FOLLOWERS",
        "INTERACTIONS",
        "MESSAGES",
        "VIEWS",
        "APPS"
    ]
    
    static func getGraphs() -> [Graph] {
        var results = [Graph]()
        let models = loadGraphs()
        guard models.count == files.count else {
            print("JSON data corrupted")
            return []
        }
        for i in models.indices {
            if let graph = GraphConverter.convert(model: models[i], name: titles[i]) {
                results.append(graph)
            }
        }
        return results
    }
    
    static private func loadGraphs() -> [GraphModel] {
        var graphs = [GraphModel]()
        for fileName in files {
            guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else { continue }
            guard let data = NSData(contentsOfFile: path) as Data? else { continue }
            do {
                let graph = try JSONDecoder().decode(GraphModel.self, from: data)
                graphs.append(graph)
            } catch {
                continue
            }
        }
        return graphs
    }
}
