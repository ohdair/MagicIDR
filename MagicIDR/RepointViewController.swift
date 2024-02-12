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

    private let backButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: imageConfig)
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = image
        buttonConfig.baseForegroundColor = .main
        return UIButton(configuration: buttonConfig)
    }()

    private let completeButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        let image = UIImage(systemName: "checkmark", withConfiguration: imageConfig)
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = image
        buttonConfig.baseForegroundColor = .main
        return UIButton(configuration: buttonConfig)
    }()

    private lazy var abilitiesStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(completeButton)
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .black.withAlphaComponent(0.1)
        return stackView
    }()

    private var rectangleView = RectangleView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()

        detectRectangle()

        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(tappedCompleteButton), for: .touchUpInside)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setUI() {
        view.backgroundColor = .white
        imageView.image = UIImage(ciImage: ciImage, scale: 1, orientation: .right)
        view.addSubview(imageView)
        view.addSubview(abilitiesStackView)
        view.addSubview(rectangleView)
    }

    private func setLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        abilitiesStackView.translatesAutoresizingMaskIntoConstraints = false
        rectangleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4/3),

            abilitiesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            abilitiesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            abilitiesStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            abilitiesStackView.heightAnchor.constraint(equalToConstant: 70),

            rectangleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rectangleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rectangleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
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
