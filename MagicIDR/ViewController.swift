//
//  ViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/1/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    private let scannerView = ScannerView()

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

    private let thumbnailView = ThumbnailView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(sutterButton)
        view.addSubview(saveButton)
        view.addSubview(thumbnailView)
        view.addSubview(scannerView)

        setNavigationBar()
        checkCameraPermissions()

        sutterButton.addTarget(self, action: #selector(tappedTakePhoto), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layerHeight = view.frame.width / 3 * 4
        let y = (view.frame.height - layerHeight) / 2
        scannerView.frame = CGRect(x: 0,
                                    y: y,
                                    width: view.frame.width,
                                    height: layerHeight)

        sutterButton.center = CGPoint(x: view.frame.width / 2,
                                      y: view.frame.height - 80)
        saveButton.center = CGPoint(x: view.frame.width - 60,
                                    y: view.frame.height - 80)
        thumbnailView.center = CGPoint(x: 60,
                                    y: view.frame.height - 80)
    }

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
            if let result = await scannerView.scan() {
                let VC = RepointViewController()
                VC.ciImage = result

                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
}
