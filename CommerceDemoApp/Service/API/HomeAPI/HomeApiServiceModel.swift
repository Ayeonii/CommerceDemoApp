//
//  HomeApiServiceModel.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/26.
//

import Foundation


struct HomeListResponse: Codable {
    let banners: [HomeListBannerResponse]?
    let goods: [HomeListGoodResponse]?
    
    enum CodingKeys: String, CodingKey {
        case banners = "banners"
        case goods = "goods"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        banners = try? values.decodeIfPresent([HomeListBannerResponse].self, forKey: .banners)
        goods = try? values.decodeIfPresent([HomeListGoodResponse].self, forKey: .goods)
    }
}

struct HomeListBannerResponse: Codable {
    let id: Int?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "goods"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decodeIfPresent(Int.self, forKey: .id)
        image = try? values.decodeIfPresent(String.self, forKey: .image)
    }
}

struct HomeListGoodResponse: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let actual_price: Int?
    let price: Int?
    let is_new: Bool?
    let sell_count: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case image = "image"
        case actual_price = "actual_price"
        case price = "price"
        case is_new = "is_new"
        case sell_count = "sell_count"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try? values.decodeIfPresent(String.self, forKey: .name)
        image = try? values.decodeIfPresent(String.self, forKey: .image)
        actual_price = try? values.decodeIfPresent(Int.self, forKey: .actual_price)
        price = try? values.decodeIfPresent(Int.self, forKey: .price)
        is_new = try? values.decodeIfPresent(Bool.self, forKey: .is_new)
        sell_count = try? values.decodeIfPresent(Int.self, forKey: .sell_count)
    }
}
