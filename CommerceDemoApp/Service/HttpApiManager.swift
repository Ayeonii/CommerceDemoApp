//
//  HttpApiManager.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/26.
//

import Foundation
import Alamofire
import RxSwift
import UIKit

class HttpAPIManager {
    class var headers: HTTPHeaders {
        let headers : HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        return headers
    }
    
    class func callRequest<T, B, P>(api: String,
                                    method: Alamofire.HTTPMethod,
                                    param : P,
                                    body: B,
                                    responseClass:T.Type) -> Observable<T>
    where T: Decodable, P: Encodable, B: Encodable {
        let urlString: String = api
        let method = method
        
        var queryparams : [String : Any] = [:]
        var bodyParam: [String: Any] = [:]
        
        do {
            let jsonEncoder = JSONEncoder()
            let paramData = try jsonEncoder.encode(param)
            if let jsonObject = try JSONSerialization.jsonObject(with: paramData, options: .allowFragments) as? [String: Any] {
                queryparams = jsonObject
            }
            
            let bodyData = try jsonEncoder.encode(body)
            if let jsonObject = try JSONSerialization.jsonObject(with: bodyData, options: .allowFragments) as? [String: Any] {
                bodyParam = jsonObject
            }
        } catch {
            return Observable.error(ApiError.encodingError(error))
        }
        
        var urlComponents = URLComponents(string: urlString)
        var urlQueryItems: [URLQueryItem] = []
        
        for (key, value) in queryparams {
            urlQueryItems.append(URLQueryItem(name: key, value: String(describing: value)))
        }
        
        if urlQueryItems.count > 0 {
            urlComponents?.queryItems = urlQueryItems
        }
        
        guard let url = urlComponents?.url else {
            return Observable.error(ApiError.inValidUrl)
        }
        
        var urlRequest = try! URLRequest(url: url, method: method, headers: headers)
        urlRequest.timeoutInterval = 30
        
        let request : DataRequest
        
        if method == .get {
            request = AF.request(urlRequest)
        } else {
            let data = try! JSONSerialization.data(withJSONObject: bodyParam, options: JSONSerialization.WritingOptions.prettyPrinted)
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            urlRequest.httpBody = json!.data(using: String.Encoding.utf8.rawValue)
            
            request = AF.request(urlRequest)
        }
        
        return self.callApi(request: request, responseClass: responseClass)
    }
    
    class func callApi<T>(request : DataRequest, responseClass : T.Type) -> Observable<T>
    where T: Decodable {
        
        return Observable.create { observer -> Disposable in
            request.responseData { (responseData) in
                
                switch responseData.result {
                case .success(let data) :
                    guard let statusCode = responseData.response?.statusCode else { return }
                    switch statusCode {
                    case (200..<300):
                        do {
                            let result = try JSONDecoder().decode(responseClass, from: data)
                            observer.onNext(result)
                            observer.onCompleted()
                        } catch {
                            observer.onError(ApiError.decodingError(error))
                        }
                    case (400..<500):
                        observer.onError(ApiError.client(statusCode, "Client has problem."))
                    default:
                        observer.onError(ApiError.server(statusCode, "Sever has problem."))
                    }
                    
                case .failure(let error) :
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}

extension HttpAPIManager {
    
    class func callRequest<T>(api: String,
                              method: Alamofire.HTTPMethod,
                              responseClass:T.Type) -> Observable<T>
    where T: Decodable {
        self.callRequest(api: api,
                         method: method,
                         param : EmptyCodable(),
                         body: EmptyCodable(),
                         responseClass: responseClass)
    }
    
    class func callRequest<T,E>(api: String,
                                method: Alamofire.HTTPMethod,
                                param : E,
                                responseClass:T.Type) -> Observable<T>
    where T: Decodable, E: Encodable {
        self.callRequest(api: api,
                         method: method,
                         param : param,
                         body: EmptyCodable(),
                         responseClass: responseClass)
    }
    
    class func callRequest<T,E>(api: String,
                                method: Alamofire.HTTPMethod,
                                body : E,
                                responseClass:T.Type) -> Observable<T>
    where T: Decodable, E: Encodable {
        self.callRequest(api: api,
                         method: method,
                         param : EmptyCodable(),
                         body: body,
                         responseClass: responseClass)
    }
    
    struct EmptyCodable: Codable {}
}
