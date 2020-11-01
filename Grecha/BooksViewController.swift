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
            $0.layer.cornerRadius = 40
            $0.backgroundColor = .blue
        }
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        grid.add(to: view).do {
            $0.contentMode = .scaleAspectFit
            $0.edgesToSuperview()
        }
        
        button.add(to: grid).do {
            $0.width(80)
            $0.height(80)
            $0.trailingToSuperview(offset: 30)
            $0.bottomToSuperview(offset: -120)
            $0.addTarget(self, action: #selector(getRecsTap), for: .touchUpInside)
        }
        
        fetchData()
    }
    
    @objc
    func getRecsTap() {
        print("recs")
        Router.pushRecs(navVC: navigationController, recs: .books(grid.selectedIDs()))
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
