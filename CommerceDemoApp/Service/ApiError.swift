//
//  ApiError.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/26.
//

import Foundation

enum ApiError: Error {
    case decodingError(Error)
    case encodingError(Error)
    case inValidUrl
    case server(Int, String?)
    case client(Int, String?)
    
    var description : String? {
        switch self {
        case .decodingError(let error):
            return "description: " + error.localizedDescription
        case .encodingError(let error):
            return "description: " + error.localizedDescription
        case .inValidUrl:
            return "description: Invalid URL"
        case .server(_, let msg),
             .client(_, let msg):
            return "description: " + (msg ?? "")
        }
    }
}

extension ApiError: LocalizedError {
    var errorDescription : String? {
        self.description
    }
    
    var failureReason : String? {
        switch self {
        case .decodingError:
            return "Decoding Error!"
        case .encodingError:
            return "Encoding Error!"
        case .inValidUrl:
            return "Invalid URL"
        case .server,
             .client:
            return "Api Error"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .decodingError:
            return "Check Decoding Type"
        case .encodingError:
            return "Check Encoding Type"
        case .inValidUrl:
            return "Check URL"
        case .server,
             .client:
            return "Retry"
        }
    }
}

extension ApiError: CustomNSError {
    static var errorDomain : String {
        return "error"
    }
    
    var errorCode : Int {
        switch self {
        case .server(let statusCode, _),
             .client(let statusCode, _):
            return statusCode
        default:
            return -1
        }
    }
    
    var errorUserInfo : [String : Any] {
        return [
            NSLocalizedDescriptionKey: errorDescription ?? "",
            NSLocalizedFailureErrorKey: failureReason ?? "",
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? ""
        ]
    }
    
    var nsError : NSError {
        return NSError(apiError : self)
    }
}



