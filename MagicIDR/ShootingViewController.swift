//
//  ShootingViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/1/24.
//

import UIKit
import SwiftUI
import AVFoundation

class ShootingViewController: UIViewController {

    private var images = ModifiedStack<UIImage>() {
        didSet {
            self.thumbnailButton.setThumbnail(image: images.top, savedImagesCount: images.count)
        }
    }

    private let scannerView = ScannerView()
    private let sutterButton = SutterButton()
    private let saveButton = UIButton()
    private let thumbnailButton = ThumbnailButton()
    private let displayController = UIHostingController(rootView: DisplayView())
    private let abilitiesView = AbilitiesView()
    private lazy var abilitiesController = UIHostingController(rootView: abilitiesView)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()

        checkCameraPermissions()
        scannerView.autoDectector.delegate = self

        sutterButton.addTarget(self, action: #selector(tappedTakePhoto), for: .touchUpInside)
        thumbnailButton.addTarget(self, action: #selector(tappedThumbnail), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(handleAutoCapture), name: .isAutoCapture, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCaptureSound), name: .isMuted, object: nil)
    }

    private func setUI() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(sutterButton)
        view.addSubview(saveButton)
        view.addSubview(thumbnailButton)
        view.addSubview(scannerView)

        addChild(displayController)
        addChild(abilitiesController)
        view.addSubview(displayController.view)
        view.addSubview(abilitiesController.view)
        displayController.view.backgroundColor = .clear
        abilitiesController.view.backgroundColor = .clear

        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
    }

    private func setLayout() {
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailButton.translatesAutoresizingMaskIntoConstraints = false
        sutterButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        displayController.view.translatesAutoresizingMaskIntoConstraints = false
        abilitiesController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            displayController.view.topAnchor.constraint(equalTo: view.topAnchor),
            displayController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            displayController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            displayController.view.bottomAnchor.constraint(equalTo: scannerView.topAnchor, constant: -5),

            scannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            scannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerView.heightAnchor.constraint(equalTo: scannerView.widthAnchor, multiplier: 4/3),

            thumbnailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            thumbnailButton.centerYAnchor.constraint(equalTo: sutterButton.centerYAnchor, constant: 5),
            thumbnailButton.widthAnchor.constraint(equalToConstant: 60),
            thumbnailButton.heightAnchor.constraint(equalToConstant: 60),

            sutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sutterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            sutterButton.widthAnchor.constraint(equalToConstant: 80),
            sutterButton.heightAnchor.constraint(equalToConstant: 80),

            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            saveButton.widthAnchor.constraint(equalToConstant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: 80),

            abilitiesController.view.topAnchor.constraint(equalTo: scannerView.bottomAnchor, constant: 5),
            abilitiesController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            abilitiesController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            abilitiesController.view.bottomAnchor.constraint(equalTo: sutterButton.topAnchor, constant: -5),
        ])
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

    @objc private func handleAutoCapture(notification: Notification) {
        guard let isAuto = notification.userInfo?[NotificationKey.isAutoCapture] as? Bool else {
            return
        }
        scannerView.autoDectector.isOn = isAuto
    }

    @objc private func handleCaptureSound(notification: Notification) {
        guard let isMuted = notification.userInfo?[NotificationKey.isMuted] as? Bool else {
            return
        }
        scannerView.muteCaptureSound(isMuted)
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
        self.sutterButton.updateProgress(0)
    }
    
    func autoDectectorDidDetected(_ autoDetector: AutoDetector, processing: CGFloat) {
        self.sutterButton.updateProgress(processing)
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
