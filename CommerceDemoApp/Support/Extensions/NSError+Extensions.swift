//
//  NSError+Extensions.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/26.
//

import Foundation

extension NSError {
    convenience init(apiError: ApiError) {
        self.init(domain: ApiError.errorDomain, code: apiError.errorCode, userInfo: apiError.errorUserInfo)
    }
}
