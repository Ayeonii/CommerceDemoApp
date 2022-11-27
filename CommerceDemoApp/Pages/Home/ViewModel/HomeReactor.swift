//
//  HomeReactor.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import Foundation
import ReactorKit

class HomeReactor: Reactor {
    typealias GoodsIndexType = (itemIndex: Int, item: GoodsItemModel)
    let disposeBag = DisposeBag()
    
    enum Action {
        case initialFetch
        case pagingGoods
        case addLikeGood(GoodsIndexType)
        case removeLikeGood(GoodsIndexType)
    }
    
    enum Mutation {
        case setBannerList([BannerItemModel])
        case setGoodsList([GoodsItemModel])
        case setLastGoodsId(Int?)
        case appendGoodsList([GoodsItemModel])
        case setInsertGoodsItems([Int])
        case setReload(Bool)
        case setPaging(Bool)
        case setRefreshing(Bool)
    }
    
    struct State {
        var bannerList: [BannerItemModel] = []
        var goodsList: [GoodsItemModel] = []
        var goodsLastId: Int?
        @Pulse var insertGoodsItems: [Int] = []
        var shouldReload: Bool = false
        var isPaging: Bool = false
        var isRefreshing: Bool = true
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initialFetch:
            return Observable.concat([
                fetchHomeList(),
                reloadAll()
            ])
            
        case .pagingGoods:
            guard let lastId = currentState.goodsLastId else { return .empty() }
            return Observable.concat([
                .just(.setPaging(true)),
                fetchGoodsListWithPaging(lastId),
                .just(.setPaging(false))
            ])
            
        case .addLikeGood(let goodsType):
            return addLikeItem(goodsType)
            
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
            
        case .setInsertGoodsItems(let items):
            newState.insertGoodsItems = items
            
        case .setReload(let shouldReload):
            newState.shouldReload = shouldReload
            
        case .setPaging(let isPaging):
            newState.isPaging = isPaging
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        
        return newState
    }
}

extension HomeReactor {
    func fetchHomeList() -> Observable<Mutation> {
        return HomeApi().getHomeList()
            .flatMap{ res -> Observable<Mutation> in
                let bannerList = res.banners?.compactMap { BannerItemModel(from: $0) } ?? []
                let likeGoodsList = UserDefaultsManager.likeList
                let goodsList = res.goods?.compactMap { GoodsItemModel(from: $0, likeList: likeGoodsList) } ?? []
                
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
    
    func fetchGoodsListWithPaging(_ lastId: Int) -> Observable<Mutation> {
        return HomeApi().getGoodsList(lastId: lastId)
            .flatMap{ [weak self] res -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                let likeGoodsList = UserDefaultsManager.likeList
                let goodsList = res.goods?.compactMap{ GoodsItemModel(from: $0, likeList: likeGoodsList) } ?? []
                let lastGoodsCount = self.currentState.goodsList.count
                let insertedItems = Array(lastGoodsCount..<(lastGoodsCount + goodsList.count))
                
                return Observable.concat([
                    .merge(.just(.appendGoodsList(goodsList)),
                           .just(.setLastGoodsId(goodsList.last?.id))),
                    .just(.setInsertGoodsItems(insertedItems))
                ])
            }
            .catch {
                return Observable.error($0)
            }
    }
    
    func addLikeItem(_ itemType: GoodsIndexType) -> Observable<Mutation> {
        let index = itemType.itemIndex
        var item = itemType.item
        item.isLike = true
        
        var currentGoods = currentState.goodsList
        currentGoods[index] = item
        
        var currentLikeGoods = UserDefaultsManager.likeList ?? []
        currentLikeGoods.insert(item, at: 0)
        UserDefaultsManager.likeList = currentLikeGoods
        
        return .just(.setGoodsList(currentGoods))
    }
    
    func removeLikeItem(_ itemType: GoodsIndexType) -> Observable<Mutation> {
        let index = itemType.itemIndex
        var item = itemType.item
        item.isLike = false
        
        var currentGoods = currentState.goodsList
        currentGoods[index] = item
        
        var currentLikeGoods = UserDefaultsManager.likeList ?? []
        if let matchedIndex = currentLikeGoods.firstIndex(where: { $0.id == item.id }) {
            currentLikeGoods.remove(at: matchedIndex)
        }
        UserDefaultsManager.likeList = currentLikeGoods
        
        return .just(.setGoodsList(currentGoods))
    }
    
    func reloadAll() -> Observable<Mutation> {
        return .concat([
            .just(.setReload(true)),
            .just(.setReload(false))
        ])
    }
}
