//
//  SegmentView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/11/24.
//

import UIKit

protocol SegmentViewDelegate: NSObject {
    func segmentViewDidChangePosition(_ segmentView: SegmentView, point: CGPoint)
}

class SegmentView: UIView {

    enum Direction {
        case top
        case right
        case bottom
        case left
    }

    let direction: Direction
    private(set) var graph: Graph

    weak var delegate: SegmentViewDelegate?

    var startPoint: CGPoint {
        didSet {
            graph = Graph(start: startPoint, end: endPoint)
            updateFrame()
        }
    }

    var endPoint: CGPoint {
        didSet {
            graph = Graph(start: startPoint, end: endPoint)
            updateFrame()
        }
    }

    private let padding = 2.0

    init(direction: Direction, start: CGPoint, end: CGPoint) {
        self.direction = direction
        self.startPoint = start
        self.endPoint = end
        self.graph = Graph(start: start, end: end)

        super.init(frame: .zero)
        backgroundColor = .clear

        updateFrame()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateFrame() {
        let minX = min(startPoint.x, endPoint.x)
        let minY = min(startPoint.y, endPoint.y)
        let maxX = max(startPoint.x, endPoint.x)
        let maxY = max(startPoint.y, endPoint.y)

        let width = maxX - minX
        let height = maxY - minY

        // 면적의 최소 너비를 padding만큼 보장 수직/수평의 직선을 표현하기 위함
        let newFrame = CGRect(x: minX - padding, y: minY - padding, width: width + (padding * 2), height: height + (padding * 2))

        self.frame = newFrame
    }

    // 터치의 범위를 프레임이 아닌 직선만 가능
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let line = line(start: startPoint, end: endPoint)
        let distance = distance(to: line, from: point)
        if distance <= 10 {
            return self
        }
        return nil
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let superview else {
            return
        }

        let currentLocation = touch.location(in: superview)
        let previousLocation = touch.previousLocation(in: superview)

        var deltaX = currentLocation.x - previousLocation.x
        var deltaY = currentLocation.y - previousLocation.y


        switch direction {
        case .top, .bottom:
            deltaX = 0
        case .left, .right:
            deltaY = 0
        }

        let point = CGPoint(x: deltaX, y: deltaY)
        guard !outOfSuperview(through: point) else {
            return
        }

        center = CGPoint(x: center.x + deltaX, y: center.y + deltaY)
        delegate?.segmentViewDidChangePosition(self, point: point)
    }

    private func outOfSuperview(through point: CGPoint) -> Bool {
        guard let superview else {
            return true
        }

        let limitX = superview.bounds.maxX
        let limitY = superview.bounds.maxY

        guard startPoint.x + point.x > 0,
              startPoint.x + point.x < limitX,
              endPoint.x + point.x > 0,
              endPoint.x + point.x < limitX,
              startPoint.y + point.y > 0,
              startPoint.y + point.y < limitY,
              endPoint.y + point.y > 0,
              endPoint.y + point.y < limitY else {
            return true
        }

        return false
    }
}

extension SegmentView: DistanceMeasurable {
    func line(start: CGPoint, end: CGPoint) -> Line {
        var lineStart: CGPoint
        var lineEnd: CGPoint

        if start.slope(to: end) < 0 {
            lineStart = CGPoint(x: bounds.maxX - padding, y: bounds.minY + padding)
            lineEnd = CGPoint(x: bounds.minX + padding, y: bounds.maxY - padding)
        } else {
            lineStart = CGPoint(x: bounds.minX + padding, y: bounds.minY + padding)
            lineEnd = CGPoint(x: bounds.maxX - padding, y: bounds.maxY - padding)
        }

        return (lineStart, lineEnd)
    }
}
