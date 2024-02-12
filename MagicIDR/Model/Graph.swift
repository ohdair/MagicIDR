//
//  Graph.swift
//  MagicIDR
//
//  Created by 박재우 on 2/11/24.
//

import Foundation

struct Graph {
    var slope: CGFloat
    var intercept: CGFloat

    init(start: CGPoint, end: CGPoint) {
        slope = (end.y - start.y) / (end.x - start.x)
        intercept = start.y - (slope * start.x)
    }
}
