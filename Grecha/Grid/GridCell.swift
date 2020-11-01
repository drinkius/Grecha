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
        static let titleFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let subtitleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        static var title: [NSAttributedString.Key: Any] {
            return [.font: titleFont,
                    .foregroundColor: UIColor.black]
        }
        static var subtitle: [NSAttributedString.Key: Any] {
            return [.font: subtitleFont,
                    .foregroundColor: UIColor.gray]
        }
    }

    static func cellHeight(for widht: CGFloat) -> CGFloat {
        return widht + Attributes.spacing + Attributes.titleFont.lineHeight
    }

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
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
        setSelected(false)
    }

    private func setup() {
        layer.cornerRadius = 5
        layer.borderColor = Theme.megaColor.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 2
        titleLabel.add(to: self).do {
            $0.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(value: 10))
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        subtitleLabel.add(to: self).do {
            $0.edgesToSuperview(excluding: [.top, .bottom], insets: UIEdgeInsets(value: 10))
            $0.topToBottom(of: titleLabel, offset: 10)
            $0.setCompressionResistance(.defaultLow, for: .vertical)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
    }

    func configure(element: GridCellElement) {
        titleLabel.attributedText = NSAttributedString(string: element.cellTitle, attributes: Attributes.title)
        titleLabel.sizeToFit()
        if let subtitle = element.cellSubtitle {
            subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: Attributes.subtitle)
            subtitleLabel.sizeToFit()
        }
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        } else {
            backgroundColor = .none
        }
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
