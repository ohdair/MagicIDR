//
//  ViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/1/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: - Property

    var session: AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()

    // MARK: - View

    private let sutterButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 20
        button.layer.borderColor = UIColor.main.cgColor
        return button
    }()

    private let saveButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private let savedCapturePhotoView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.backgroundColor = .sub
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.addSublayer(previewLayer)
        view.addSubview(sutterButton)
        view.addSubview(saveButton)
        view.addSubview(savedCapturePhotoView)

        setNavigationBar()

        checkCameraPermissions()
        sutterButton.addTarget(self, action: #selector(tappedTakePhoto), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layerHeight = view.frame.width / 3 * 4
        let y = (view.frame.height - layerHeight) / 2
        previewLayer.frame = CGRect(x: 0,
                                    y: y,
                                    width: view.frame.width,
                                    height: layerHeight)

        sutterButton.center = CGPoint(x: view.frame.width / 2,
                                      y: view.frame.height - 80)
        saveButton.center = CGPoint(x: view.frame.width - 60,
                                    y: view.frame.height - 80)
        savedCapturePhotoView.center = CGPoint(x: 60,
                                    y: view.frame.height - 80)
    }

    // MARK: - Method

    private func setNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = .black.withAlphaComponent(0.5)
        self.navigationController?.navigationBar.tintColor = .white

        self.navigationItem.leftBarButtonItem = .init(title: "취소")
        self.navigationItem.rightBarButtonItem = .init(title: "자동/수동")
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session

                self.session = session

                DispatchQueue.global(qos: .background).async {
                    self.session?.startRunning()
                }
            } catch {
                print(error)
            }
        }
    }

    @objc private func tappedTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: data)

        session?.stopRunning()

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}
