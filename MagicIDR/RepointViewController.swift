//
//  RepointViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/2/24.
//

import UIKit

protocol RepointViewControllerDelegate: NSObject {
    func repointViewControllerWillDisappear(_ repointViewController: RepointViewController, image: CIImage?, rectangleFeature: RectangleFeature?)
}

class RepointViewController: UIViewController, RectangleDetectable {

    var ciImage: CIImage!

    weak var delegate: RepointViewControllerDelegate?

    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var backBarButtonItem = {
        let buttonItem = UIBarButtonItem()
        buttonItem.tintColor = .white
        buttonItem.image = UIImage(systemName: "chevron.backward")
        buttonItem.action = #selector(tappedBackButton)
        buttonItem.target = self
        return buttonItem
    }()

    private lazy var completeButtonItem = {
        let buttonItem = UIBarButtonItem()
        buttonItem.tintColor = .white
        buttonItem.image = UIImage(systemName: "checkmark")
        buttonItem.action = #selector(tappedCompleteButton)
        buttonItem.target = self
        return buttonItem
    }()

    private var rectangleView = RectangleView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()

        detectRectangle()
    }

    private func setUI() {
        imageView.image = UIImage(ciImage: ciImage, scale: 1, orientation: .right)
        view.addSubview(imageView)
        view.addSubview(rectangleView)
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.backgroundColor = .clear
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.rightBarButtonItem = completeButtonItem
    }

    private func setLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        rectangleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4/3),

            rectangleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rectangleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rectangleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rectangleView.heightAnchor.constraint(equalTo: rectangleView.widthAnchor, multiplier: 4/3),
        ])
    }

    private func detectRectangle() {
        DispatchQueue.main.async { [self] in
            guard let rectangleFeature = detectRectangle(in: ciImage) else {
                rectangleView.setFullCorner()
                return
            }

            let scale = ciImage.extent.height / rectangleView.bounds.width
            let adjustmentFeauture = RectangleFeatureAdjustmetor(rectangleFeature).adjustRectangle(with: scale)

            rectangleView.setFeature(adjustmentFeauture)
        }
    }

    @objc private func tappedBackButton() {
        delegate?.repointViewControllerWillDisappear(self, image: nil, rectangleFeature: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func tappedCompleteButton() {
        let scale = rectangleView.bounds.width / ciImage.extent.height 
        let feature = RectangleFeatureAdjustmetor(rectangleView.feature).adjustRectangle(with: scale)
        delegate?.repointViewControllerWillDisappear(self, image: ciImage, rectangleFeature: feature)
        self.navigationController?.popViewController(animated: true)
    }
}
