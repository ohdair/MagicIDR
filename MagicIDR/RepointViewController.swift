//
//  RepointViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/2/24.
//

import UIKit

class RepointViewController: UIViewController {

    var image: UIImage!

    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
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
        view.backgroundColor = .systemPink
        imageView.image = image
        view.addSubview(imageView)
    }

    private func setLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4/3)
        ])
    }
}
