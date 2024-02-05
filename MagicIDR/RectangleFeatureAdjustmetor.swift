//
//  RectangleFeatureAdjustmetor.swift
//  MagicIDR
//
//  Created by 박재우 on 2/5/24.
//

import Foundation
import CoreImage

class RectangleFeatureAdjustmetor: NSObject {

    private var topLeft: CGPoint
    private var topRight: CGPoint
    private var bottomLeft: CGPoint
    private var bottomRight: CGPoint

    private var centerPoint : CGPoint {
        get {
            let leftX = (topLeft.x + bottomLeft.x) / 2
            let rightX = (topRight.x + bottomRight.x) / 2
            let centerX = (leftX + rightX) / 2

            let topY = (topRight.y + topLeft.y) / 2
            let bottomY = (bottomRight.y + bottomLeft.y) / 2
            let centerY = (topY + bottomY) / 2
            return CGPoint(x: centerX, y: centerY)
        }

    }

    init(_ rectangleFeature: CIRectangleFeature) {
        topLeft = rectangleFeature.topLeft
        topRight = rectangleFeature.topRight
        bottomLeft = rectangleFeature.bottomLeft
        bottomRight = rectangleFeature.bottomRight
    }

    func adjustRectangle(with scale: CGFloat) -> (
        topLeft: CGPoint,
        topRight: CGPoint,
        bottomLeft: CGPoint,
        bottomRight: CGPoint
    ) {
        scaleRect(with: scale)
        rotate90Degree()
        correctOriginPoints()

        return (topLeft, topRight, bottomLeft, bottomRight)
    }

    private func rotate90Degree() {
        let centerPoint = self.centerPoint

        topLeft = CGPoint(x: centerPoint.x + (topLeft.y - centerPoint.y),
                          y: centerPoint.y + (topLeft.x - centerPoint.x))
        topRight = CGPoint(x: centerPoint.x + (topRight.y - centerPoint.y),
                           y: centerPoint.y + (topRight.x - centerPoint.x))
        bottomLeft = CGPoint(x: centerPoint.x + (bottomLeft.y - centerPoint.y),
                             y: centerPoint.y + (bottomLeft.x - centerPoint.x))
        bottomRight = CGPoint(x: centerPoint.x + (bottomRight.y - centerPoint.y),
                              y: centerPoint.y + (bottomRight.x - centerPoint.x))
    }

    private func scaleRect(with scale: CGFloat) {
        topLeft =  topLeft.scale(with: scale)
        topRight = topRight.scale(with: scale)
        bottomLeft = bottomLeft.scale(with: scale)
        bottomRight = bottomRight.scale(with: scale)
    }

    private func correctOriginPoints() {
        let deltaCenter = self.centerPoint.reverse().substracting(self.centerPoint)

        let TL = topLeft.adding(deltaCenter)
        let TR = topRight.adding(deltaCenter)
        let BL = bottomLeft.adding(deltaCenter)
        let BR = bottomRight.adding(deltaCenter)

        topLeft = BL
        topRight = TL
        bottomLeft = BR
        bottomRight = TR
    }
}

fileprivate extension CGPoint {
    func scale(with scale: CGFloat) -> CGPoint {
        return CGPoint(x: self.x/scale, y: self.y/scale)
    }

    func reverse() -> CGPoint {
        return CGPoint(x: self.y, y: self.x)
    }

    func adding(_ addPoint: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + addPoint.x, y: self.y + addPoint.y)
    }

    func substracting(_ subPoint: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - subPoint.x, y: self.y - subPoint.y)
    }
}