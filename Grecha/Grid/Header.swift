//
//  FriendshipComponentHeaderView.swift
//  Reach
//
//  Created by Telegin on 21.10.2020.
//  Copyright © 2020 Project Cohort Inc. All rights reserved.
//

import UIKit

final class Header: UICollectionReusableView {

    private enum Attributes {
        static func titleLabel() -> [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 24),
                    .foregroundColor: UIColor.black]
        }

        static var subtitleLabel: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 18),
                    .foregroundColor: UIColor.gray]
        }

        static var goalsCount: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.blue]
        }
    }

    private lazy var title: UILabel = {
        return UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }()

    private lazy var sublitle: UILabel = {
        return UILabel().then {
            $0.numberOfLines = 0
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }()

    private lazy var detailsLabel: UILabel = {
        return UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: (String, String, String?)) {

        title.attributedText = NSAttributedString(string: model.0, attributes: Attributes.titleLabel())
        sublitle.attributedText = NSAttributedString(string: model.1, attributes: Attributes.subtitleLabel)
        detailsLabel.attributedText = NSAttributedString(string: "\(model.2 ?? "")", attributes: Attributes.goalsCount)
    }

    private func setupViews() {

        let titleStack = UIStackView(arrangedSubviews: [title, detailsLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false

        titleStack.alignment = .fill
        titleStack.distribution = .equalSpacing
        titleStack.axis = .horizontal

        addSubview(titleStack)
        addSubview(sublitle)

        NSLayoutConstraint.activate([
            titleStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            titleStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            titleStack.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            sublitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            sublitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            sublitle.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 12),
            sublitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
}
