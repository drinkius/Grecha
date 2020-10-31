import SwiftyJSON
import UIKit

public protocol JSONable {
  init(json: JSON) throws
}

// Not sure about this implementation
/*
extension Array: JSONable where Element: JSONable {
    public init(json: JSON) throws {
        guard let array = json.array else {
            throw JSONError.parseError
        }
        self = array.compactMap { try? Element(json: $0) }
    }
}
*/

extension JSON {

    public func value<T: JSONable>(for key: String) throws -> T {
        try T(json: self[key])
    }

    public func value<T: JSONable>() throws -> T {
        try T(json: self)
    }

    public func value<T: JSONable>(for key: String) throws -> [T] {
        if let value = self[key].array {
            return value.compactMap { try? T(json: $0) }
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> [String: [String]] {
        if let dict = self[key].dictionary {
            var response = [String: [String]]()
            for key in dict.keys {
                // Not entirely sure this is correct
                response[key] = dict[key]?.array?.compactMap { $0.string }
            }
            return response
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> String {
        if let value = self[key].string,
            !value.isEmpty {
            return value
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> [String] {
        if let value = self[key].array {
            return value.compactMap { $0.string }
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> Int {
        if let value = self[key].int {
            return value
        } else if let valueString = self[key].string,
            let value = Int(valueString) {
            return value
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> Double {
        if let value = self[key].double {
            return value
        } else if let valueString = self[key].string,
        let value = Double(valueString) {
            return value
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> Float {
        if let value = self[key].float {
            return value
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> Bool {
        let value = self[key]
            if let bool = self[key].bool {
            return bool
        } else if let string = value.string, ["0", "1"].contains(string) {
            return string == "1"
        } else if let integer = value.int, [0, 1].contains(integer) {
            return integer == 1
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    private static let formatter: DateFormatter = {
        // Regarding en_US_POSIX:
        // https://developer.apple.com/library/archive/qa/qa1480/_index.html
        // https://stackoverflow.com/questions/41907419/ios-swift-3-convert-yyyy-mm-ddthhmmssz-format-string-to-date-object
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        formatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        return formatter
    }()

    public func value(for key: String) throws -> Date {
        if let value = self[key].string,
            let date = JSON.formatter.date(from: value) {
            return date
        } else {
            throw JSONError.missingValue(key: key)
        }
    }

    public func value(for key: String) throws -> URL {
        if let value = self[key].string,
            let url = URL(string: value) {
            return url
        } else {
            throw JSONError.missingValue(key: key)
        }
    }
}

public enum JSONError: Error, CustomStringConvertible {
    case missingValue(key: String)
    case parseError

    public var description: String {
        switch self {
        case let .missingValue(key):
            return "Null Value found at: \(key)"
        case .parseError:
            return "Couldn't parse object"
        }
  }
}

class JSONBox: JSONable {

    public var json: JSON

    public required init(json: JSON) throws {
        self.json = json
    }
}
