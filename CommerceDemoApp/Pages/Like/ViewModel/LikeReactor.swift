//
//  LikeReactor.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import Foundation
import ReactorKit

class LikeReactor: Reactor {
    let disposeBag = DisposeBag()
    
    enum Action {
        case getLikeGoodsList
    }
    
    enum Mutation {
        case setGoodsList([GoodsItemModel])
        case setReload(Bool)
    }
    
    struct State {
        @Pulse var goodsList: [GoodsItemModel] = []
        var shouldReload: Bool = false
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getLikeGoodsList:
            let likeList = UserDefaultsManager.likeList ?? []
            return Observable.concat([.just(.setGoodsList(likeList)),
                                      reloadAll()])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setGoodsList(let goodsList):
            newState.goodsList = goodsList
   
        case .setReload(let shouldReload):
            newState.shouldReload = shouldReload
        }
        
        return newState
    }
}

extension LikeReactor {
    func reloadAll() -> Observable<Mutation> {
        return .concat([
            .just(.setReload(true)),
            .just(.setReload(false))
        ])
    }
}

