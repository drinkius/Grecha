//
//  GridCollection.swift
//  Grecha
//
//  Created by Telegin on 01.11.2020.
//

import UIKit

protocol GridCellElement {
    var cellTitle: String { get }
    var cellSubtitle: String? { get }
}

class GridCollection: UIView {
    
    private enum Attributes {
        static let interItemSpacing: CGFloat = 20
        static let lineSpacing: CGFloat = 24
        static let leftRightInsets: CGFloat = 18
        static let cellWidth: CGFloat = {
            let screenWidth = UIScreen.main.bounds.width
            return (screenWidth - 2 * leftRightInsets - 3 * interItemSpacing) / 4
        }()
    }
    
    private let title: String
    private let subtitle: String
    
    private lazy var collectionView: UICollectionView = {
        return  UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
            $0.dataSource = self
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
            $0.register(GridCell.self, forCellWithReuseIdentifier: "gridcell")
            $0.register(Header.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "header")
        }
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        return UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = Attributes.lineSpacing
            $0.minimumInteritemSpacing = Attributes.interItemSpacing
            $0.sectionInset = UIEdgeInsets(top: Attributes.lineSpacing, left: Attributes.leftRightInsets,
                                           bottom: Attributes.lineSpacing, right: Attributes.leftRightInsets)
        }
    }()
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var items = [GridCellElement]()
    
    func setItems(_ items: [GridCellElement]) {
        self.items = items
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension GridCollection: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridcell",
                                                      for: indexPath) as! GridCell
        cell.configure(element: items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! Header
        return headerView
    }
}

extension GridCollection: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Attributes.cellWidth, height: GridCell.cellHeight(for: Attributes.cellWidth))
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
}
