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
