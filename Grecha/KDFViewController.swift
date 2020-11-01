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
        
        title = "Выберите КДФ"
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: Theme.megaColor]
        
        let img = UIImage(named: "gerb")!.withRenderingMode(.alwaysOriginal)
        let leftBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
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
            let alert = UIAlertController.alert(title: "Ошибка", message: "Выберите как минимум один КДФ")
            alert.addAction(title: "OK")
            navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        Router.pushRecs(navVC: navigationController, recs: .kdfs(ids))
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
            let toShow = Array(kdfs.choose(100))
            self?.grid.setItems(toShow)
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

extension Collection {
    func choose(_ n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
}
