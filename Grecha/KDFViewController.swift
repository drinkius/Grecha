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
    }
}
