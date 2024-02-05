//
//  ThumbnailView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/5/24.
//

import UIKit

class ThumbnailButton: UIButton {

    private let countLabel = {
        let label = UILabel()
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.backgroundColor = .systemYellow
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let thumbnailImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.main
        return imageView
    }()

    private var images = [UIImage]() {
        didSet {
            countLabel.text = "\(images.count)"
            thumbnailImageView.image = images.last
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        countLabel.text = "\(images.count)"
        thumbnailImageView.image = images.last

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

            countLabel.widthAnchor.constraint(equalToConstant: 30),
            countLabel.heightAnchor.constraint(equalToConstant: 30),
            countLabel.centerXAnchor.constraint(equalTo: trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: topAnchor)
        ])
    }

    func push(_ ciImage: CIImage) {
        let image = UIImage(ciImage: ciImage)
        images.append(image)
    }

    @discardableResult
    func pop() -> UIImage {
        images.removeLast()
    }
}
