//
//  CornerView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/8/24.
//

import UIKit

protocol CornerViewDelegate: NSObject {
    func pointViewDidChangePosition(cornerView: CornerView, point: CGPoint)
}

class CornerView: UIView {

    enum Direction {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    let direction: Direction

    weak var delegate: CornerViewDelegate?

    init(direction: Direction, point: CGPoint) {
        self.direction = direction
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

        backgroundColor = .main.withAlphaComponent(0.5)
        layer.cornerRadius = 10
        center = point
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let superview else {
            return
        }

        let currentLocation = touch.location(in: superview)
        let previousLocation = touch.previousLocation(in: superview)

        var deltaX = self.center.x + (currentLocation.x - previousLocation.x)
        var deltaY = self.center.y + (currentLocation.y - previousLocation.y)

        deltaX = min(superview.bounds.maxX, deltaX)
        deltaX = max(superview.bounds.minX, deltaX)

        deltaY = min(superview.bounds.maxY, deltaY)
        deltaY = max(superview.bounds.minY, deltaY)

        let point = CGPoint(x: deltaX, y: deltaY)
        self.center = point
        delegate?.pointViewDidChangePosition(cornerView: self, point: point)
    }
}
