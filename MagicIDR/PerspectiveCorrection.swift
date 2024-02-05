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

    func correct() -> CGImage? {
        guard let rectangleFeature = detectRectangle(in: originImage) else {
            return nil
        }

        let topLeft = CIVector(cgPoint: rectangleFeature.topLeft)
        let topRight = CIVector(cgPoint: rectangleFeature.topRight)
        let bottomLeft = CIVector(cgPoint: rectangleFeature.bottomLeft)
        let bottomRight = CIVector(cgPoint: rectangleFeature.bottomRight)

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

        guard let outputImage = perspectiveFilter.outputImage else {
            return nil
        }

        let ciContext = CIContext(options: nil)

        return ciContext.createCGImage(outputImage, from: outputImage.extent)
    }
}
