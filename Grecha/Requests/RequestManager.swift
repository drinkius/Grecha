//
//  RequestManager.swift
//  Seen
//
//  Created by Alex Telegin on 23/03/2018.
//  Copyright © 2018 Seen Corp. All rights reserved.
//

import Foundation
import SwiftyJSON
import SystemConfiguration

private struct Links {
    static let books = "http://35.198.119.173:8000/books/12345"
    static let recs = "http://35.198.119.173:8000/recs/269"
    static let listKDFs = "http://35.198.119.173:8000/get_all_kdf"
    static let kdfRecs = "http://35.198.119.173:8000/recs_kdf/103695"
}

enum RequestType {

    typealias Interval = Int

    case getBooks
    case getAllKDFs
    case getKDFRecs

    func path() -> String {
        switch self {
        case .getBooks:
            return Links.books
        case .getAllKDFs:
            return Links.listKDFs
        case .getKDFRecs:
            return Links.kdfRecs
        }
    }
}

typealias RequestCompletion = (RequestResult?, Error?) -> Void

struct RequestResult {
    let data: Any?
    let headers: [String: String]

    static func with(_ data: Any?) -> RequestResult {
        return RequestResult(data: data, headers: [:])
    }
}

class RequestManager: NSObject {

    static let shared = RequestManager()
    private override init() { }
    var token: String = "null"
    let requestQueue = DispatchQueue(label: "com.grecha.requestQueue",
                                     qos: .utility)

    var twitterAuthCompletion: RequestCompletion?

    fileprivate func _authGetHeader() -> [String : String] {
        var header: [String : String] = [
            "Content-Type": "application/json"
        ]
        if token != "null" {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }

    fileprivate func _preAuthPostHeader() -> [String : String] {
        return [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
    }

    fileprivate func _authPostHeader() -> [String : String] {
        var header = _preAuthPostHeader()
        header["Authorization"] = "Bearer \(token)"
        return header
    }

    func basePost(type: RequestType,
                  customURL: String? = nil,
                  params: [String: String] = [:],
                  headers: [String: String] = [:],
                  bodyData: Data? = nil,
                  bodyJSON: JSON? = nil,
                  bodyDict: [String: Any]? = nil,
                  auth: Bool = false,
                  completion: @escaping RequestCompletion) {
        let url = type.path()
        var header: [String: String] = [:]
        if auth {
            header = _preAuthPostHeader()
        } else {
            header = _authPostHeader() + headers
        }
        let data: Data?
        if let body = bodyData {
            data = body
        } else if let bodyJSON = bodyJSON {
            data = try? bodyJSON.rawData()
        } else if let bodyDict = bodyDict {
            data = try? JSON(bodyDict).rawData()
        } else {
            data = nil
        }

        if disconnected {
            completion(nil, NetworkError.internetFail)
            return
        }

        requestQueue.async {
            Just.post(url,
                      params: params,
                      headers: header,
                      requestBody: data) { response in
                        if let content = response.content, let code = response.statusCode {
                            print("\nPOST (\(response.ok ? "Success" : "Error"))\n" +
                                "URL: \(url)\nERROR CODE: \(String(describing: response.statusCode))")
                            print("Trace ID: \(response.headers["uber-trace-id"] ?? "missing")\n")
                            if !response.ok {
                                print(JSON(content))
                            }
                            self.onDataReceived(data: try? JSON(data: content),
                                                headers: response.headers,
                                                type: type,
                                                method: HTTPMethod.post,
                                                params: params,
                                                isError: !response.ok,
                                                code: code,
                                                completion: completion)
                        } else {
                            completion(nil, RequestError.unknownError)
                        }
            }
        }
    }

    func baseGet(type: RequestType,
                 params: [String: String] = [:],
                 headers: [String: String] = [:],
                 completion: @escaping RequestCompletion) {
        let header = _authGetHeader() + headers
        let url = type.path()

        if disconnected {
            completion(nil, NetworkError.internetFail)
            return
        }

        requestQueue.async {
            Just.get(url,
                     params: params,
                     headers: header) { response in
                        print("\nGET (\(response.ok ? "Success" : "Error"))\n" +
                            "URL: \(url)\nERROR CODE: \(String(describing: response.statusCode))")
                        print("Trace ID: \(response.headers["uber-trace-id"] ?? "missing")\n")
                        if let content = response.content, let code =  response.statusCode {
                            self.onDataReceived(data: try? JSON(data: content),
                                                headers: response.headers,
                                                type: type,
                                                method: HTTPMethod.get,
                                                params: params,
                                                isError: false,
                                                code: code,
                                                completion: completion)
                        } else {
                            completion(nil, RequestError.unknownError)
                        }
            }
        }
    }

    func getData(request: RequestType,
                 parameters: [String: String],
                 page: Int,
                 perPage: Int? = nil,
                 completion: @escaping RequestCompletion) {
        var params: [String: String] = [
            "page": "\(page)"
        ]
        params = params + parameters
        if let perPage = perPage {
            params["per_page"] = "\(perPage)"
        }
        baseGet(type: request,
                params: params,
                completion: completion)
    }
}

extension RequestManager {
    static let restUrl = "http://35.232.69.112:8080"
}

extension RequestManager {
    // Checking connection
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }

    var disconnected: Bool {
        return currentReachabilityStatus == .notReachable
    }

    private var currentReachabilityStatus: ReachabilityStatus {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }

        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        } else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        } else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required
            // then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        } else if (flags.contains(.connectionOnDemand) == true ||
            flags.contains(.connectionOnTraffic) == true) &&
            flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application
            // is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        } else {
            return .notReachable
        }
    }
}

func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach { result[$0] = $1 }
    return result
}

public enum NetworkError: Int, Error, CustomStringConvertible, CustomNSError, LocalizedError {

    case internetFail
    case serverFail
    case noFacebookToken
    case tokenExpired

    public static var errorDomain: String {
        return "NetworkError"
    }

    public var errorCode: Int {
        return self.rawValue
    }

    public var errorUserInfo: [String : Any] {
        return ["ErrorDescription": description]
    }

    public var description: String {
        switch self {
        case .internetFail:
            return "Internet connection problems"
        case .serverFail:
            return "Server unavailable"
        case .noFacebookToken:
            return "Missing FacebookToken"
        case .tokenExpired:
            return "Token expired"
        }
    }

    public var errorDescription: String? {
        return description
    }
}
