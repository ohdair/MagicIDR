//
//  ThumbnailButton.swift
//  MagicIDR
//
//  Created by 박재우 on 2/5/24.
//

import UIKit

class ThumbnailButton: UIButton {

    private let countLabel = {
        let label = UILabel()
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.backgroundColor = .systemYellow
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let thumbnailImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .white.withAlphaComponent(0.2)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        countLabel.text = "0"

        addSubview(thumbnailImageView)
        addSubview(countLabel)
    }

    private func setLayout() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            countLabel.widthAnchor.constraint(equalToConstant: 20),
            countLabel.heightAnchor.constraint(equalToConstant: 20),
            countLabel.centerXAnchor.constraint(equalTo: trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: topAnchor)
        ])
    }

    func setThumbnail(image: UIImage?, savedImagesCount count: Int) {
        countLabel.text = "\(count)"
        thumbnailImageView.image = image
    }
}
