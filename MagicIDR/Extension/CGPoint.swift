//
//  CGPoint.swift
//  MagicIDR
//
//  Created by 박재우 on 2/12/24.
//

import Foundation

extension CGPoint {
    func distance(to destination: CGPoint) -> CGFloat {
        sqrt(pow(destination.x - self.x, 2) + pow(destination.y - self.y, 2))
    }

    func slope(to destination: CGPoint) -> CGFloat {
        (destination.y - self.y) / (destination.x - self.x)
    }

    func adding(point: CGPoint) -> CGPoint {
        let newX = self.x + point.x
        let newY = self.y + point.y
        return CGPoint(x: newX, y: newY)
    }
}
