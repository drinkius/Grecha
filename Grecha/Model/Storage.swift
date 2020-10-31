//
//  Storage.swift
//  Grecha
//
//  Created by Telegin on 01.11.2020.
//

import Foundation

class Storage {
    static var kdfs: [KDF]? {
        set {
            if let kdfs = newValue {
                let strings: [String] = kdfs.map { $0.jsonString() }
                UserDefaults.standard.set(strings, forKey: "kdfs")
            } else {
                UserDefaults.standard.set(nil, forKey: "kdfs")
            }
            
        } get {
            guard let strings: [String] = UserDefaults.standard.object(forKey: "kdfs") as? [String] else { return nil }
            return strings.compactMap { try? KDF(stringJSON: $0) }
        }
    }
}
