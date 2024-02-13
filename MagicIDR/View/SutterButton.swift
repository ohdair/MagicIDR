//
//  SutterButton.swift
//  MagicIDR
//
//  Created by 박재우 on 2/13/24.
//

import UIKit

class SutterButton: UIButton {

    private let progressBarLayer = CAShapeLayer()
    private let innerLayer = CAShapeLayer()
    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        setProgressBarLayer()
        setInnerLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setInnerLayer() {
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 40, y: 40),
                                        radius: 30,
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: true)

        innerLayer.path = circularPath.cgPath
        innerLayer.strokeColor = UIColor.main.cgColor
        innerLayer.fillColor = nil
        innerLayer.lineWidth = 20

        layer.addSublayer(innerLayer)
    }

    private func setProgressBarLayer() {
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 40, y: 40),
                                        radius: 40,
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: true)

        progressBarLayer.path = circularPath.cgPath
        progressBarLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.9).cgColor
        progressBarLayer.fillColor = nil
        progressBarLayer.lineWidth = 10
        progressBarLayer.lineCap = .round
        progressBarLayer.strokeEnd = 0

        layer.addSublayer(progressBarLayer)
    }

    func updateProgress(_ progress: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.progressBarLayer.strokeEnd = progress
        }
    }
}
