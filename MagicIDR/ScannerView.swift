//
//  ScannerView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/2/24.
//

import UIKit

class ScannerView: UIView {

    private let scanner = Scanner()

    override init(frame: CGRect) {
        super.init(frame: frame)
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

    func scan() async -> UIImage? {
        await scanner.scan()
    }
}
