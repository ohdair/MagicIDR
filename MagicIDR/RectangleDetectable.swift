//
//  RectangleDetectable.swift
//  MagicIDR
//
//  Created by 박재우 on 2/5/24.
//

import CoreImage

protocol RectangleDetectable { }

extension RectangleDetectable {
    func detectRectangle(in image: CIImage) -> CIRectangleFeature? {
        let detector = CIDetector(
            ofType: CIDetectorTypeRectangle,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        let feature = detector?.features(in: image).first
        return feature as? CIRectangleFeature
    }
}
