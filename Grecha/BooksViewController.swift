//
//  ViewController.swift
//  Grecha
//
//  Created by Telegin on 31.10.2020.
//

import UIKit

class ViewController: UIViewController {
    
    let grid = GridCollection(title: "Выберите КДФ интересные вам",
                              subtitle: "Можно выбрать несколько элементов")
    
    lazy var button: UIButton = {
        let button = UIButton(frame: .zero).then {
            let height: CGFloat = 60
            let inset: CGFloat = 20
            $0.height(height)
            $0.layer.cornerRadius = height / 2
            $0.backgroundColor = Theme.megaColor
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            $0.setTitle("Рекомендации", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.adjustsFontSizeToFitWidth = false
            $0.sizeToFit()
            $0.width($0.frame.width + inset * 2)
        }
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Выберите любимые книги"
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: Theme.megaColor]
        
        grid.add(to: view).do {
            $0.contentMode = .scaleAspectFit
            $0.edgesToSuperview()
        }
        
        button.add(to: grid).do {
            $0.trailingToSuperview(offset: 30)
            $0.bottomToSuperview(offset: -120)
            $0.addTarget(self, action: #selector(getRecsTap), for: .touchUpInside)
        }
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        grid.deselectAll()
    }
    
    @objc
    func getRecsTap() {
        let ids = grid.selectedIDs()
        guard ids.count > 0 else {
            let alert = UIAlertController.alert(title: "Ошибка", message: "Выберите как минимум одну книгу")
            alert.addAction(title: "OK")
            navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        Router.pushRecs(navVC: navigationController, recs: .books(ids))
    }
    
    private func fetchData() {
        RequestManager.shared.baseGet(type: .getBooks) { [weak self] (result, error) in
            guard error == nil else {
                dump(error)
                return
            }
            guard let data = (result?.data as? JSON) else {
                return
            }
            var books = [Book]()
            for json in data["books"].arrayValue {
                if let kdf = try? Book(json: json) {
                    books.append(kdf)
                }
            }
            self?.grid.setItems(books)
        }
    }
}
