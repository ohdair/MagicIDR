//
//  RectangleView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/4/24.
//

import UIKit

class RectangleView: UIView {

    private var topLeftPoint: CGPoint = .zero {
        didSet {
            topView.startPoint = topLeftPoint
            leftView.endPoint = topLeftPoint
        }
    }
    private var topRightPoint: CGPoint = .zero {
        didSet {
            rightView.startPoint = topRightPoint
            topView.endPoint = topRightPoint
        }
    }
    private var bottomLeftPoint: CGPoint = .zero {
        didSet {
            leftView.startPoint = bottomLeftPoint
            bottomView.endPoint = bottomLeftPoint
        }
    }
    private var bottomRightPoint: CGPoint = .zero {
        didSet {
            bottomView.startPoint = bottomRightPoint
            rightView.endPoint = bottomRightPoint
        }
    }

    private var detectedTopLeftPoint: CGPoint?
    private var detectedTopRightPoint: CGPoint?
    private var detectedBottomLeftPoint: CGPoint?
    private var detectedBottomRightPoint: CGPoint?

    private var topLeftView: CornerView!
    private var topRightView: CornerView!
    private var bottomLeftView: CornerView!
    private var bottomRightView: CornerView!

    private var topView: SegmentView!
    private var rightView: SegmentView!
    private var bottomView: SegmentView!
    private var leftView: SegmentView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        topLeftView.center = topLeftPoint
        topRightView.center = topRightPoint
        bottomLeftView.center = bottomLeftPoint
        bottomRightView.center = bottomRightPoint

        setNeedsDisplay()
    }

    private func setUI() {
        topLeftView = CornerView(direction: .topLeft, point: topLeftPoint)
        topRightView = CornerView(direction: .topRight, point: topRightPoint)
        bottomLeftView = CornerView(direction: .bottomLeft, point: bottomLeftPoint)
        bottomRightView = CornerView(direction: .bottomRight, point: bottomRightPoint)

        topView = SegmentView(direction: .top, start: topLeftPoint, end: topRightPoint)
        rightView = SegmentView(direction: .right, start: topRightPoint, end: bottomRightPoint)
        bottomView = SegmentView(direction: .bottom, start: bottomRightPoint, end: bottomLeftPoint)
        leftView = SegmentView(direction: .left, start: bottomLeftPoint, end: topLeftPoint)

        addSubview(topView)
        addSubview(rightView)
        addSubview(bottomView)
        addSubview(leftView)
        addSubview(topLeftView)
        addSubview(topRightView)
        addSubview(bottomLeftView)
        addSubview(bottomRightView)

        topLeftView.delegate = self
        topRightView.delegate = self
        bottomLeftView.delegate = self
        bottomRightView.delegate = self
        topView.delegate = self
        rightView.delegate = self
        bottomView.delegate = self
        leftView.delegate = self

        backgroundColor = .clear
    }

    func setFeature(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        topLeftPoint = topLeft
        topRightPoint = topRight
        bottomLeftPoint = bottomLeft
        bottomRightPoint = bottomRight

        detectedTopLeftPoint = topLeft
        detectedTopRightPoint = topRight
        detectedBottomLeftPoint = bottomLeft
        detectedBottomRightPoint = bottomRight

        layoutSubviews()
    }

    func setFullCorner() {
        topLeftPoint = CGPoint(x: bounds.minX + 10, y: bounds.minY + 10)
        topRightPoint = CGPoint(x: bounds.maxX - 10, y: bounds.minY + 10)
        bottomLeftPoint = CGPoint(x: bounds.minX + 10, y: bounds.maxY - 10)
        bottomRightPoint = CGPoint(x: bounds.maxX - 10, y: bounds.maxY - 10)

        layoutSubviews()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(2)
        context.setStrokeColor(UIColor.sub.cgColor)
        context.move(to: topLeftPoint)
        context.addLine(to: topRightPoint)
        context.addLine(to: bottomRightPoint)
        context.addLine(to: bottomLeftPoint)
        context.closePath()
        context.strokePath()
    }
}

extension RectangleView: CornerViewDelegate, SegmentViewDelegate {
    func pointViewDidChangePosition(cornerView: CornerView, point: CGPoint) {
        switch cornerView.direction {
        case .topLeft:
            topLeftPoint = point
        case .topRight:
            topRightPoint = point
        case .bottomLeft:
            bottomLeftPoint = point
        case .bottomRight:
            bottomRightPoint = point
        }

        setNeedsDisplay()
    }

    func segmentViewDidChangePosition(segmentView: SegmentView, point: CGPoint) {
        let centerPoint = segmentView.center.adding(point: point)

        switch segmentView.direction {
        case .top:
            if isNearbyRectangle(with: segmentView.direction, from: centerPoint) {
                topLeftPoint = detectedTopLeftPoint!
                topRightPoint = detectedTopRightPoint!
            } else {
                topLeftPoint = topLeftPoint.adding(point: point)
                topRightPoint = topRightPoint.adding(point: point)
            }
        case .right:
            if isNearbyRectangle(with: segmentView.direction, from: centerPoint) {
                topRightPoint = detectedTopRightPoint!
                bottomRightPoint = detectedBottomRightPoint!
            } else {
                topRightPoint = topRightPoint.adding(point: point)
                bottomRightPoint = bottomRightPoint.adding(point: point)
            }
        case .bottom:
            if isNearbyRectangle(with: segmentView.direction, from: centerPoint) {
                bottomRightPoint = detectedBottomRightPoint!
                bottomLeftPoint = detectedBottomLeftPoint!
            } else {
                bottomRightPoint = bottomRightPoint.adding(point: point)
                bottomLeftPoint = bottomLeftPoint.adding(point: point)
            }
        case .left:
            if isNearbyRectangle(with: segmentView.direction, from: centerPoint) {
                bottomLeftPoint = detectedBottomLeftPoint!
                topLeftPoint = detectedTopLeftPoint!
            } else {
                bottomLeftPoint = bottomLeftPoint.adding(point: point)
                topLeftPoint = topLeftPoint.adding(point: point)
            }
        }

        setNeedsDisplay()
    }

    func isNearbyRectangle(with direction: SegmentView.Direction, from point: CGPoint) -> Bool {
        guard let detectedTopLeftPoint,
              let detectedTopRightPoint,
              let detectedBottomLeftPoint,
              let detectedBottomRightPoint else {
            return false
        }

        var rectangleLine: Line

        switch direction {
        case .top:
            rectangleLine = line(start: detectedTopLeftPoint, end: detectedTopRightPoint)
        case .right:
            rectangleLine = line(start: detectedTopRightPoint, end: detectedBottomRightPoint)
        case .bottom:
            rectangleLine = line(start: detectedBottomRightPoint, end: detectedBottomLeftPoint)
        case .left:
            rectangleLine = line(start: detectedBottomLeftPoint, end: detectedTopLeftPoint)
        }

        return distance(to: rectangleLine, from: point) <= 10
    }
}

extension RectangleView: DistanceMeasurable {
    func line(start: CGPoint, end: CGPoint) -> Line {
        return (start, end)
    }
}
