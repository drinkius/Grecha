//
//  Router.swift
//  Grecha
//
//  Created by Telegin on 01.11.2020.
//

import UIKit

class Router {
    static func pushRecs(navVC: UINavigationController?, recs: RecsVC.Recs) {
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "recs") as! RecsVC
        vc.recs = recs
        navVC?.pushViewController(vc, animated: true)
    }
}
