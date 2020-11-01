//
//  KDFViewController.swift
//  Grecha
//
//  Created by Telegin on 01.11.2020.
//

import UIKit

class RecsVC: UIViewController {
    
    enum Recs {
        case kdfs([Int])
    }
    
    let grid = GridCollection(title: "Выберите КДФ интересные вам",
                              subtitle: "Можно выбрать несколько элементов")
    
    var recs: Recs? {
        didSet {
            guard let recs = recs else { return }
            switch recs {
            case .kdfs(let list):
                getRecs(for: list)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        grid.add(to: view).do {
            $0.contentMode = .scaleAspectFit
            $0.edgesToSuperview()
        }

        fetchData()
    }
    
    private func fetchData() {
        RequestManager.shared.baseGet(type: .getAllKDFs) { [weak self] (result, error) in
            guard error == nil else {
                dump(error)
                return
            }
            guard let data = (result?.data as? JSON) else {
                return
            }
            var kdfs = [KDF]()
            for json in data.arrayValue {
                if let kdf = try? KDF(json: json) {
                    kdfs.append(kdf)
                }
            }
            Storage.kdfs = kdfs
            self?.grid.setItems(kdfs)
            print(kdfs.count)
            print("")
            
//            self?.getRecs(for: [])
        }
    }
    
    private func getRecs(for kdfs: [Int]) {
        let ids: [Int] = [326, 419, 836]
        let paramsJSON: JSON = JSON(["kdfs": ids])
        RequestManager.shared.basePost(type: .getKDFRecs,
                                       bodyJSON: paramsJSON) { (result, error) in
            guard error == nil else {
                dump(error)
                return
            }
            guard let data = (result?.data as? JSON) else {
                return
            }
            var kdfs = [KDF]()
            for json in data["kdfs"].arrayValue {
                if let kdf = try? KDF(json: json, recID: true) {
                    kdfs.append(kdf)
                }
            }
            print(kdfs.count)
            print("")
        }
    }
}
