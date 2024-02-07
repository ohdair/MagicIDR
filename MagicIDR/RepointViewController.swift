//
//  RepointViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/2/24.
//

import UIKit

class RepointViewController: UIViewController {

    var ciImage: CIImage!

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()
    }

    private func setUI() {
        view.backgroundColor = .white
        imageView.image = UIImage(ciImage: ciImage, scale: 1, orientation: .right)
        view.addSubview(imageView)
        view.addSubview(abilitiesStackView)
    }

    private func setLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        abilitiesStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4/3),

            abilitiesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            abilitiesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            abilitiesStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            abilitiesStackView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}
