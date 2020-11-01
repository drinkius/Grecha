//
//  GridCell.swift
//  Grecha
//
//  Created by Telegin on 21.10.2020.
//  Copyright © 2020. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {

    private enum Attributes {
        static let spacing: CGFloat = 12
        static let titleFont = UIFont.systemFont(ofSize: 14)
        static var title: [NSAttributedString.Key: Any] {
            return [.font: titleFont,
                    .foregroundColor: UIColor.black]
        }
    }

    static func cellHeight(for widht: CGFloat) -> CGFloat {
        return widht + Attributes.spacing + Attributes.titleFont.lineHeight
    }

    private let titleLabel = UILabel()
    private let imageView = UIImageView()

    override init(frame: CGRect) {
      super.init(frame: frame)
      setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func setup() {
        titleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.bottomAnchor),
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                $0.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            ])
        }
    }

    func configure(element: GridCellElement) {
        titleLabel.attributedText = NSAttributedString(string: element.cellTitle, attributes: Attributes.title)
    }
}

fileprivate extension NSAttributedString {

    func height(containerWidth: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }
}
