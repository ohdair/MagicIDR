//
//  DistanceMeasurable.swift
//  MagicIDR
//
//  Created by 박재우 on 2/12/24.
//

import Foundation

protocol DistanceMeasurable {
    typealias Line = (start: CGPoint, end: CGPoint)

    func distance(to line: Line, from point: CGPoint) -> CGFloat
    func line(start: CGPoint, end: CGPoint) -> Line
}

extension DistanceMeasurable {
    func distance(to line: Line, from point: CGPoint) -> CGFloat {
        // 점과 직선 사이의 거리 공식
        let numerator = abs((line.end.y - line.start.y) * point.x - (line.end.x - line.start.x) * point.y + line.end.x * line.start.y - line.end.y * line.start.x)
        let denominator = line.start.distance(to: line.end)
        return numerator / denominator
    }
}
