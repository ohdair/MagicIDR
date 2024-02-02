//
//  Scanner.swift
//  MagicIDR
//
//  Created by 박재우 on 2/2/24.
//

import AVFoundation
import UIKit

class Scanner: NSObject {

    private let session = AVCaptureSession()
    private let device = AVCaptureDevice.default(for: .video)
    private var input: AVCaptureDeviceInput?
    private let output = AVCapturePhotoOutput()

    lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    private var scanSuccessBlock: ((UIImage?) -> Void)?

    override init() {
        super.init()

        guard let device else { return }

        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            print("capture device input Error: \(error.localizedDescription)")
        }

        guard let input else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }
    }

    func start() {
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func scan() async -> UIImage? {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)

        return await withCheckedContinuation { continuation in
            request(complition: { result in
                continuation.resume(returning: result)
            })
        }
    }

    private func request(complition: @escaping (UIImage?) -> Void) {
        scanSuccessBlock = complition
    }
}

extension Scanner: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        stop()
        
        if error != nil {
            scanSuccessBlock?(nil)
            return
        }
        
        if let data = photo.fileDataRepresentation() {
            let image = UIImage(data: data)
            scanSuccessBlock?(image)
        }
    }
}
