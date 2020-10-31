//
//  RequestManager+ResponseHandler.swift
//  Seen
//
//  Created by Alex Telegin on 23/03/2018.
//  Copyright © 2018 Seen Corp. All rights reserved.
//

import Foundation
import SwiftyJSON

extension RequestManager {
    func onDataReceived(data: JSON?,
                        headers: CaseInsensitiveDictionary<String, String>,
                        type: RequestType,
                        method: HTTPMethod,
                        params: [String: Any],
                        isError: Bool,
                        code: Int,
                        completion: RequestCompletion) {

        // Logout on receiving "Unauthorized"
        if isError, code == 401 {
            return
        }

        guard let data = data else {
            if code >= 200 && code < 300 {
                completion(nil, nil)
            } else {
                completion(nil, RequestError.unknownError)
            }
            return
        }

        switch type {
        default:
            if isError {
                completion(nil, RequestError(rawValue: code) ?? RequestError.unknownError)
            } else {
                completion(RequestResult(data: data, headers: headers._data), nil)
            }
            break
        }
    }
}

public enum RequestError: Int, Error, CustomStringConvertible, CustomNSError, LocalizedError {

    case unknownError = -1
    case badParameters = -2
    case unknownRequest = 0
    case badRequest = 400
    case notFound = 404

    public var description: String {
        switch self {
        case .unknownError:
            return "Unknown error"
        case .badParameters:
            return "Bad parameters"
        case .unknownRequest:
            return "Unknown request"
        case .badRequest:
            return "Bad request - missing data?"
        case .notFound:
            return "Not found"
        }
    }

    // MARK: CustomNSError

    public static var errorDomain: String {
        return "RequestError"
    }

    public var errorCode: Int {
        return self.rawValue
    }

    public var errorUserInfo: [String : Any] {
        return ["ErrorDescription": description]
    }

    public var errorDescription: String? {
        return description
    }
}
