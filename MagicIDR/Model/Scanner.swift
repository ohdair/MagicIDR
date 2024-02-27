//
//  Scanner.swift
//  MagicIDR
//
//  Created by 박재우 on 2/2/24.
//

import AVFoundation
import CoreImage

protocol ScannerDelegate: AnyObject {
    func scanner(_ scan: Scanner, capturedVideo: CIImage)
}

class Scanner: NSObject {

    private let session = AVCaptureSession()
    private let device = AVCaptureDevice.default(for: .video)
    private var input: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()

    lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    weak var snannerDelegate: ScannerDelegate?

    private var scanSuccessBlock: ((CIImage?) -> Void)?

    var isMuted: Bool = true

    override init() {
        super.init()

        guard let device else { return }

        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            print("capture device input Error: \(error.localizedDescription)")
        }

        guard let input else { return }

        session.sessionPreset = .photo

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(videoOutput)
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

    func scan() async -> CIImage? {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)

        return await withCheckedContinuation { continuation in
            scanSuccessBlock = { image in
                continuation.resume(returning: image)
            }
        }
    }
}

extension Scanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if isMuted {
            AudioServicesDisposeSystemSoundID(1108)
        } else {
            AudioServicesPlaySystemSound(1108)
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        snannerDelegate?.scanner(self, capturedVideo: ciImage)
    }
}

extension Scanner: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            scanSuccessBlock?(nil)
            return
        }

        if let data = photo.fileDataRepresentation() {
            let image = CIImage(data: data)
            scanSuccessBlock?(image)
        }
    }
}
