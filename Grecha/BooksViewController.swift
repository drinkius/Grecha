//
//  ViewController.swift
//  Grecha
//
//  Created by Telegin on 31.10.2020.
//

import UIKit

class ViewController: UIViewController {
    
    let placeholder = UIImageView(image: UIImage(named: "grecha"))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeholder.add(to: view).do {
            $0.contentMode = .scaleAspectFit
            $0.edgesToSuperview(insets: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40))
        }
        
        fetchData()
    }
    
    private func fetchData() {
        RequestManager.shared.baseGet(type: .getBooks) { (result, error) in
            guard error == nil else {
                dump(error)
                return
            }
            guard let data = (result?.data as? JSON) else {
                return
            }
            var books = [Book]()
            for json in data.arrayValue {
                if let kdf = try? Book(json: json) {
                    books.append(kdf)
                }
            }
            print(books.count)
            print("")
        }
    }
    
    private func getRecs(for books: [Book]) {
        
    }
}
