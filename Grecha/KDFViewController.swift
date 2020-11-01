//
//  KDFViewController.swift
//  Grecha
//
//  Created by Telegin on 01.11.2020.
//

import UIKit

class KDFViewController: UIViewController {
    
    let placeholder = UIImageView(image: UIImage(named: ""))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeholder.add(to: view).do {
            $0.contentMode = .scaleAspectFit
            $0.edgesToSuperview(insets: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40))
        }
        
        fetchData()
    }
    
    
    
    private func fetchData() {
        RequestManager.shared.baseGet(type: .getAllKDFs) { (result, error) in
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
            print(kdfs.count)
            print("")
            
            self.getRecs(for: [])
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
