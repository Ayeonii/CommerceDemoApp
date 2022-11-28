//
//  CallApi.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/26.
//

import Foundation
import RxSwift
import RxCocoa

struct HomeApi {
    enum EndPoint {
        case homeList
        case goodsList
    
        var url: String {
            let endPoint = "http://d2bab9i9pr8lds.cloudfront.net/api/home"
            switch self {
            case .homeList:
                return endPoint
            case .goodsList:
                return endPoint + "/goods"
            }
        }
    }
}

extension HomeApi {
    func getHomeList() -> Observable<HomeListResponse> {
        let apiUrl = EndPoint.homeList.url
        
        return HttpAPIManager.callRequest(api: apiUrl,
                                          method: .get,
                                          responseClass: HomeListResponse.self)
    }
    
    func getGoodsList(lastId: Int) -> Observable<HomeListResponse> {
        let apiUrl = EndPoint.goodsList.url
        
        struct Param: Codable {
            var lastId: Int
        }

        return HttpAPIManager.callRequest(api: apiUrl,
                                          method: .get,
                                          param: Param(lastId: lastId),
                                          responseClass: HomeListResponse.self)
    }
    
}

