//
//  SutterButton.swift
//  MagicIDR
//
//  Created by 박재우 on 2/13/24.
//

import UIKit

class SutterButton: UIButton {

    private let progressBarLayer = CAShapeLayer()
    private var progress: CGFloat = 0
    private let buttonImageView = UIImageView(image: UIImage(systemName: "button.programmable")?.withTintColor(.white, renderingMode: .alwaysOriginal))

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(buttonImageView)
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonImageView.topAnchor.constraint(equalTo: topAnchor),
            buttonImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        setProgressBarLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        progressBarLayer.strokeColor = UIColor.systemYellow.cgColor
        progressBarLayer.fillColor = nil
        progressBarLayer.lineWidth = 5
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
