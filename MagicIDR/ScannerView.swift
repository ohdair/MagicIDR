//
//  ScannerView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/2/24.
//

import UIKit

class ScannerView: UIView {

    private let scanner = Scanner()

    private var detectedRectangleLayer = CAShapeLayer() {
        didSet {
            detectedRectangleLayer.removeFromSuperlayer()
            layer.addSublayer(detectedRectangleLayer)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        scanner.snannerDelegate = self
        layer.addSublayer(scanner.cameraLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scanner.cameraLayer.frame = bounds
    }

    func startScanning() {
        scanner.start()
    }

    func stopScanning() {
        scanner.stop()
    }

    func scan() async -> CIImage? {
        await scanner.scan()
    }
}

extension ScannerView: ScannerDelegate, RectangleDetectable {
    func scanner(_ scan: Scanner, capturedVideo: CIImage) {
        DispatchQueue.main.async {
            guard let rectangleFeature = self.detectRectangle(in: capturedVideo) else { return }
            let adjustmentRectangleFeature =  RectangleFeatureAdjustmetor(rectangleFeature)

            let scale = capturedVideo.extent.height / self.bounds.width
            let newFeature = adjustmentRectangleFeature.adjustRectangle(with: scale)

            let path = UIBezierPath()
            path.move(to: newFeature.topLeft)
            path.addLine(to: newFeature.topRight)
            path.addLine(to: newFeature.bottomRight)
            path.addLine(to: newFeature.bottomLeft)
            path.close()

            let layer = CAShapeLayer()
            layer.fillColor = UIColor.main.withAlphaComponent(0.5).cgColor
            layer.strokeColor = UIColor.sub.cgColor
            layer.lineWidth = 3
            layer.path = path.cgPath

            self.detectedRectangleLayer = layer
        }
    }
}
