//
//  AutoDetector.swift
//  MagicIDR
//
//  Created by 박재우 on 2/13/24.
//

import Foundation

protocol AutoDectectorable: NSObject {
    func autoDectectorWillDetected(_ autoDetector: AutoDetector)
    func autoDectectorDidDetected(_ autoDetector: AutoDetector, processing: CGFloat)
    func autoDectectorCompleted(_ autoDetector: AutoDetector)
}

class AutoDetector {

    var isOn: Bool = true {
        didSet {
            resetTimer()
        }
    }

    private var isRectangleDetected: Bool = false
    private var timer: Timer?
    private var processing: CGFloat = 0

    weak var delegate: AutoDectectorable?

    func detect(_ isDetected: Bool) {
        if isOn, isDetected != isRectangleDetected {
            isRectangleDetected = isDetected
            if isRectangleDetected {
                startTimer()
            } else {
                resetTimer()
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }

    private func resetTimer() {
        processing = 0
        isRectangleDetected = false
        timer?.invalidate()
    }

    @objc private func fireTimer() {
        processing += 0.2
        delegate?.autoDectectorDidDetected(self, processing: processing)

        if processing >= 1.0 {
            delegate?.autoDectectorCompleted(self)
            resetTimer()
        }
    }
}
