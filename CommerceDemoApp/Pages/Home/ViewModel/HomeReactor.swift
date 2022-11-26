//
//  HomeReactor.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import Foundation
import ReactorKit

class HomeReactor: Reactor {
    let disposeBag = DisposeBag()
    
    enum Action {
        case initialFetch
        case pagingGoods
        case addLikeGood(GoodsItemModel)
        case removeLikeGood(GoodsItemModel)
    }
    
    enum Mutation {
        case setBannerList([BannerItemModel])
        case setGoodsList([GoodsItemModel])
        case setLastGoodsId(Int?)
        case appendGoodsList([GoodsItemModel])
        case setReload(Bool)
    }
    
    struct State {
        var bannerList: [BannerItemModel] = []
        var goodsList: [GoodsItemModel] = []
        var goodsLastId: Int?
        var shouldReload: Bool = false
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initialFetch:
            return Observable.concat([fetchHomeList(), reloadAll()])
            
        case .pagingGoods:
            return fetchGoodsListWithPaging()
            
        case .addLikeGood(let item):
            return addLikeItem(item)
            
        case .removeLikeGood(let item):
            return removeLikeItem(item)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setBannerList(let bannerList):
            newState.bannerList = bannerList
            
        case .setGoodsList(let goodsList):
            newState.goodsList = goodsList
            
        case .appendGoodsList(let goodsList):
            newState.goodsList.append(contentsOf: goodsList)
            
        case .setLastGoodsId(let id):
            newState.goodsLastId = id
            
        case .setReload(let shouldReload):
            newState.shouldReload = shouldReload
        }
        
        return newState
    }
}

extension HomeReactor {
    func fetchHomeList() -> Observable<Mutation> {
        return HomeApi().getHomeList()
            .flatMap{ res -> Observable<Mutation> in
                let bannerList = res.banners?.compactMap { BannerItemModel(from: $0) } ?? []
                let goodsList = res.goods?.compactMap { GoodsItemModel(from: $0) } ?? []
                
                return Observable.merge(
                    .just(.setBannerList(bannerList)),
                    .just(.setGoodsList(goodsList)),
                    .just(.setLastGoodsId(goodsList.last?.id))
                )
            }
            .catch {
                print("error: \($0)")
                return Observable.error($0)
            }
    }
    
    func fetchGoodsListWithPaging() -> Observable<Mutation> {
        guard let lastId = currentState.goodsLastId else { return .empty() }
        
        return HomeApi().getGoodsList(lastId: lastId)
            .flatMap{ res -> Observable<Mutation> in
                let goodsList = res.goods?.compactMap { GoodsItemModel(from: $0) } ?? []
                return Observable.merge(
                    .just(.setGoodsList(goodsList)),
                    .just(.setLastGoodsId(goodsList.last?.id))
                )
            }
            .catch {
                return Observable.error($0)
            }
    }
    
    func addLikeItem(_ item: GoodsItemModel) -> Observable<Mutation> {
        return .empty()
    }
    
    func removeLikeItem(_ item: GoodsItemModel) -> Observable<Mutation> {
        return .empty()
    }
    
    func reloadAll() -> Observable<Mutation> {
        return .concat([
            .just(.setReload(true)),
            .just(.setReload(false))
        ])
    }
}
