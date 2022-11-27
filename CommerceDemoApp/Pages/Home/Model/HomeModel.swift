//
//  HomeModel.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import Foundation


struct BannerItemModel {
    var id: Int?
    var image: String
    
    init(from res: HomeListBannerResponse?) {
        self.id = res?.id
        self.image = res?.image ?? ""
    }
}

struct GoodsItemModel {
    var id: Int?
    var name: String
    var image: String
    var isNew: Bool
    var sellCount: Int
    var actualPrice: Int
    var price: Int
    var discountPercent: Int
    var isLike: Bool = false
    var likeAvailable: Bool = true
    
    init(from res: HomeListGoodResponse?, isLikeAvailable: Bool) {
        self.id = res?.id
        self.name = res?.name ?? ""
        self.image = res?.image ?? ""
        self.isNew = res?.is_new ?? false
        self.sellCount = res?.sell_count ?? 0
    
        let price = res?.price ?? 0
        let actual = res?.actual_price ?? 0
        self.price = price
        self.actualPrice = actual
        self.discountPercent = (actual == 0) ? 0 : Int(ceil(Double((price * 100) / actual)))
        self.likeAvailable = isLikeAvailable
    }
}

