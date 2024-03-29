//
//  PerspectiveCorrection.swift
//  MagicIDR
//
//  Created by 박재우 on 2/5/24.
//

import CoreImage

class PerspectiveCorrection: RectangleDetectable {

    private var originImage: CIImage

    init(image: CIImage) {
        self.originImage = image
    }

    func correctImage() -> CIImage? {
        guard let rectangleFeature = detectRectangle(in: originImage) else {
            return nil
        }

        let feature = RectangleFeature(topLeft: rectangleFeature.topLeft,
                                       topRight: rectangleFeature.topRight,
                                       bottomLeft: rectangleFeature.bottomLeft,
                                       bottomRight: rectangleFeature.bottomRight)
        return correctionImage(through: feature)
    }

    func correctionImage(through feature: RectangleFeature) -> CIImage? {
        let topLeft = CIVector(cgPoint: feature.topLeft)
        let topRight = CIVector(cgPoint: feature.topRight)
        let bottomLeft = CIVector(cgPoint: feature.bottomLeft)
        let bottomRight = CIVector(cgPoint: feature.bottomRight)

        guard let perspectiveFilter = CIFilter(name: "CIPerspectiveCorrection") else {
            return nil
        }

        perspectiveFilter.setValuesForKeys([
            kCIInputImageKey: originImage,
            "inputTopLeft": topLeft,
            "inputTopRight": topRight,
            "inputBottomLeft": bottomLeft,
            "inputBottomRight": bottomRight
        ])

        return perspectiveFilter.outputImage
    }
}
