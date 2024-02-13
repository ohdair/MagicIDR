//
//  ToggleButton.swift
//  MagicIDR
//
//  Created by 박재우 on 2/13/24.
//

import UIKit

class ToggleButton: UIButton {

    private(set) var isMenual: Bool = false
    private let checkView = UIView()
    private var constraint: NSLayoutConstraint!
    private let menualLabel = UILabel()
    private let automaticalLabel = UILabel()

    init() {
        super.init(frame: .zero)

        setUI()

        addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        addSubview(checkView)
        addSubview(menualLabel)
        addSubview(automaticalLabel)

        translatesAutoresizingMaskIntoConstraints = false
        checkView.translatesAutoresizingMaskIntoConstraints = false
        menualLabel.translatesAutoresizingMaskIntoConstraints = false
        automaticalLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 100),
            heightAnchor.constraint(equalToConstant: 36),

            checkView.widthAnchor.constraint(equalToConstant: 46),
            checkView.heightAnchor.constraint(equalToConstant: 28),
            checkView.centerYAnchor.constraint(equalTo: centerYAnchor),

            menualLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            menualLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            automaticalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            automaticalLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        constraint = checkView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
        constraint.isActive = true

        layer.cornerRadius = 18
        backgroundColor = .black.withAlphaComponent(0.2)

        checkView.layer.cornerRadius = 14
        checkView.backgroundColor = .white.withAlphaComponent(0.2)
        checkView.isUserInteractionEnabled = false

        menualLabel.text = "수동"
        menualLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        menualLabel.textColor = .white.withAlphaComponent(0.4)
        automaticalLabel.text = "자동"
        automaticalLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        automaticalLabel.textColor = .white
    }

    @objc private func toggle() {
        isMenual.toggle()

        UIView.animate(withDuration: 0.4) {
            self.constraint.isActive = false

            if self.isMenual {
                self.constraint = self.checkView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
            } else {
                self.constraint = self.checkView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5)
            }

            self.constraint.isActive = true
            self.layoutIfNeeded()
        }

        UIView.transition(with: self, duration: 0.4, options: .transitionCrossDissolve) {
            if self.isMenual {
                self.automaticalLabel.textColor = .white.withAlphaComponent(0.4)
                self.menualLabel.textColor = .white
            } else {
                self.menualLabel.textColor = .white.withAlphaComponent(0.4)
                self.automaticalLabel.textColor = .white
            }

            self.layoutIfNeeded()
        }
    }
}
