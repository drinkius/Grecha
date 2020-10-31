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
    }
}
