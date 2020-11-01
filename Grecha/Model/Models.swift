//
//  Models.swift
//  Grecha
//
//  Created by Telegin on 01.11.2020.
//

import Foundation
import SwiftyJSON

class Book: JSONable {
    
    let recordId: Int
    let author: String
    let title: String
    let year: String
    let genres: String
    
    public convenience init(stringJSON string: String) throws {
        let json = JSON(stringLiteral: string)
        try self.init(json: json)
    }

    required init(json: JSON) throws {
        print(json)
        recordId = try json.value(for: "record_id")
        author = try json.value(for: "author")
        title = try json.value(for:  "title")
        year = try json.value(for: "year")
        genres = try json.value(for: "genres")
    }
    
    private func dict() -> [String: Any?] {
        let dict: [String: Any?] = [
            "record_id": recordId,
            "author": author,
            "title": title,
            "year": year,
            "genres": genres,
        ]
        return dict
    }

    public func jsonString() -> String {
        let json = JSON(dict())
        return json.toString()
    }
}

extension Book: GridCellElement {
    var cellTitle: String {
        return title
    }
    
    var cellSubtitle: String? {
        return author
    }
    
    var idForRequest: Int {
        return recordId
    }
}

class KDF {

    let name: String
    let id: Int
    
    public convenience init(stringJSON string: String) throws {
        let json = JSON(stringLiteral: string)
        try self.init(json: json)
    }
    
    required init(json: JSON, recID: Bool = false) throws {
        id = try json.value(for: recID ? "rec_id" : "id")
        name = try json.value(for: "name")
    }
    
    private func dict() -> [String: Any?] {
        let dict: [String: Any?] = [
            "id": id,
            "name": name,
        ]
        return dict
    }

    public func jsonString() -> String {
        let json = JSON(dict())
        return json.toString()
    }
}

extension KDF: GridCellElement {
    var cellTitle: String {
        return name
    }
    
    var cellSubtitle: String? {
        return nil
    }
    
    var idForRequest: Int {
        return id
    }
}
