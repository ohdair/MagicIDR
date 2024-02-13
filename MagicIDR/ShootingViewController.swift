//
//  ShootingViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/1/24.
//

import UIKit
import AVFoundation

class ShootingViewController: UIViewController {

    private var images = ModifiedStack<UIImage>() {
        didSet {
            self.thumbnailButton.setThumbnail(image: images.top, savedImagesCount: images.count)
        }
    }

    private let scannerView = ScannerView()
    private let sutterButton = UIButton()
    private let saveButton = UIButton()
    private let thumbnailButton = ThumbnailButton()
    private let toggleButton = ToggleButton()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()

        checkCameraPermissions()
        scannerView.autoDectector.delegate = self

        sutterButton.addTarget(self, action: #selector(tappedTakePhoto), for: .touchUpInside)
        thumbnailButton.addTarget(self, action: #selector(tappedThumbnail), for: .touchUpInside)
        toggleButton.addTarget(self, action: #selector(tappedToggleButton), for: .touchUpInside)
    }

    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(sutterButton)
        view.addSubview(saveButton)
        view.addSubview(thumbnailButton)
        view.addSubview(scannerView)

        sutterButton.layer.cornerRadius = 40
        sutterButton.layer.borderWidth = 20
        sutterButton.layer.borderColor = UIColor.main.cgColor

        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
    }

    private func setLayout() {
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailButton.translatesAutoresizingMaskIntoConstraints = false
        sutterButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            scannerView.heightAnchor.constraint(equalTo: scannerView.widthAnchor, multiplier: 4/3),

            thumbnailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            thumbnailButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            thumbnailButton.widthAnchor.constraint(equalToConstant: 80),
            thumbnailButton.heightAnchor.constraint(equalToConstant: 80),

            sutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sutterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            sutterButton.widthAnchor.constraint(equalToConstant: 80),
            sutterButton.heightAnchor.constraint(equalToConstant: 80),

            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            saveButton.widthAnchor.constraint(equalToConstant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    private func setNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = .black.withAlphaComponent(0.5)
        self.navigationController?.navigationBar.tintColor = .white

        self.navigationItem.leftBarButtonItem = .init(title: "취소")
        self.navigationItem.rightBarButtonItem = .init(customView: toggleButton)
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                
                DispatchQueue.main.async {
                    self?.scannerView.startScanning()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            scannerView.startScanning()
        @unknown default:
            break
        }
    }

    @objc private func tappedTakePhoto() {
        Task {
            defer {
                sutterButton.isEnabled = true
            }

            sutterButton.isEnabled = false
            guard let result = await scannerView.scan() else {
                print("카메라 촬영에 실패하였습니다.")
                return
            }

            scannerView.stopScanning()

            let repointViewController = RepointViewController()
            repointViewController.ciImage = result
            repointViewController.delegate = self

            self.navigationController?.pushViewController(repointViewController, animated: true)
        }
    }

    @objc private func tappedThumbnail() {
        guard !images.isEmpty else {
            return
        }

        scannerView.stopScanning()

        let previewViewController = PreviewViewController()
        previewViewController.images = images
        previewViewController.delegate = self

        self.navigationController?.pushViewController(previewViewController, animated: true)
    }

    @objc private func tappedToggleButton(sender: ToggleButton) {
        if sender.isMenual {
            scannerView.autoDectector.isOn = false
        } else {
            scannerView.autoDectector.isOn = true
        }
    }
}

extension ShootingViewController: RepointViewControllerDelegate {
    func repointViewControllerWillDisappear(_ repointViewController: RepointViewController, image: CIImage?, rectangleFeature: RectangleFeature?) {
        scannerView.startScanning()

        guard let image, let rectangleFeature else { return }

        var newImage: UIImage

        if let cgImage = PerspectiveCorrection(image: image).correct(with: rectangleFeature) {
            newImage = UIImage(cgImage: cgImage, scale: 1, orientation: .left)
        } else {
            newImage = UIImage(ciImage: image, scale: 1, orientation: .left)
        }

        images.push(newImage)
    }
}

extension ShootingViewController: AutoDectectorable {
    func autoDectectorWillDetected(_ autoDetector: AutoDetector) {

    }
    
    func autoDectectorDidDetected(_ autoDetector: AutoDetector, processing: CGFloat) {

    }

    func autoDectectorCompleted(_ autoDetector: AutoDetector) {
        Task {
            guard let result = await scannerView.scan() else {
                print("카메라 촬영에 실패하였습니다.")
                return
            }

            var image: UIImage

            if let perspectiveCorrection = PerspectiveCorrection(image: result).correct() {
                image = UIImage(cgImage: perspectiveCorrection, scale: 1, orientation: .right)
            } else {
                image = UIImage(ciImage: result, scale: 1, orientation: .right)
            }

            images.push(image)
        }
    }
}

extension ShootingViewController: PreviewViewControllerDelegate {
    func previewViewControllerWillDisappear(_ previewViewController: PreviewViewController, images: ModifiedStack<UIImage>) {
        scannerView.startScanning()
        self.images = images
    }
}
