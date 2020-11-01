//
//  KDFViewController.swift
//  Grecha
//
//  Created by Telegin on 01.11.2020.
//

import UIKit

class KDFViewController: UIViewController {
    
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
        Router.pushRecs(navVC: navigationController, recs: .kdfs(grid.selectedIDs()))
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
    
    private func getRecs(for kdfs: [KDF]) {
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
