//
//  ContentViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/6/24.
//

import UIKit

class ContentViewController: UIViewController {
    private let imageView = UIImageView()
    var pageIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4/3)
        ])
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }
}
