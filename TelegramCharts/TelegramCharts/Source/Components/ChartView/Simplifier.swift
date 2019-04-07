//
//  Simplifier.swift
//  TelegramCharts
//
//  Created by Rost on 06/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import UIKit

class Simplifier {
    
    class func simplify(_ points: [CGPoint], tolerance: CGFloat?) -> [CGPoint] {
        if points.count <= 2 {
            return points
        }
        let squareTolerance = tolerance!//(tolerance != nil ? tolerance! * tolerance! : 1.0)
        var result: [CGPoint] = points
        result = simplifyDouglasPeucker(result, tolerance: squareTolerance)
        return result
    }
    
    // MARK: - Private
    
    private class func getSquareSegmentDistance(point p: CGPoint, seg1 s1: CGPoint, seg2 s2: CGPoint) -> CGFloat {
        
        var x = s1.x
        var y = s1.y
        var dx = s2.x - x
        var dy = s2.y - y
        
        if dx != 0 || dy != 0 {
            let t = ((p.x - x) * dx + (p.y - y) * dy) / ((dx * dx) + (dy * dy))
            if t > 1 {
                x = s2.x
                y = s2.y
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }
        dx = p.x - x
        dy = p.y - y
        
        return dx * dx + dy * dy
    }
    
    private class func simplifyDouglasPeucker(_ points: [CGPoint], tolerance: CGFloat!) -> [CGPoint] {
        if points.count <= 2 {
            return points
        }
        
        let lastPoint: Int = points.count - 1
        var result: [CGPoint] = [points.first!]
        simplifyDouglasPeuckerStep(points, first: 0, last: lastPoint, tolerance: tolerance, simplified: &result)
        result.append(points[lastPoint])
        return result
    }
    
    private class func simplifyDouglasPeuckerStep(_ points: [CGPoint], first: Int, last: Int, tolerance: CGFloat, simplified: inout [CGPoint]) {
        var maxSquareDistance = tolerance
        var index = 0
        
        for i in first + 1 ..< last {
            let sqDist = getSquareSegmentDistance(point: points[i], seg1: points[first], seg2: points[last])
            if sqDist > maxSquareDistance {
                index = i
                maxSquareDistance = sqDist
            }
        }
        
        if maxSquareDistance > tolerance {
            if index - first > 1 {
                simplifyDouglasPeuckerStep(points, first: first, last: index, tolerance: tolerance, simplified: &simplified)
            }
            simplified.append(points[index])
            if last - index > 1 {
                simplifyDouglasPeuckerStep(points, first: index, last: last, tolerance: tolerance, simplified: &simplified)
            }
        }
    }
}
