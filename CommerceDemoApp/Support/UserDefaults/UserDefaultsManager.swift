//
//  UserDefaultsManager.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/27.
//

import Foundation

struct UserDefaultsManager {
    @UserDefaultsWrapper(key: "likeGoodsList", value: nil)
    static var likeList: [GoodsItemModel]?
}

@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {
    private let key: String
    private let value: T?
    
    init(key: String, value: T?) {
        self.key = key
        self.value = value
    }
    
    var wrappedValue: T? {
        get {
            if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                if let lodedObejct = try? decoder.decode(T.self, from: savedData) {
                    return lodedObejct
                }
            }
            return value
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.setValue(encoded, forKey: key)
            }
        }
    }
}
